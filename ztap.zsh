() {
  typeset -gx ZTAP_HOME=${${(%):-%x}:A:h}
  autoload -U colors && colors
}

function ztap() {
  local ZTAP_TESTNUM=0
  local ZTAP_PASSED=0
  local ZTAP_FAILED=0
  local ZTAP_TESTNUM_TOTAL=0
  local ZTAP_PASSED_TOTAL=0
  local ZTAP_FAILED_TOTAL=0
  local ZTAP_COLORIZE=true
  local green=$fg[green]
  local red=$fg[red]
  local nocolor=$reset_color

  case $1 in
    -v|--version)
        echo "ztap, version 1.0.0"
        return
        ;;
    -h|--help)
        echo "Usage: ztap <files...>"
        echo "Options"
        echo "  -v --version    Print version"
        echo "  -h --help       Print this help message"
        echo "  -p --plaintext  Do not colorize output"
        return
        ;;
    -p|--plaintext)
        shift
        local ZTAP_COLORIZE=false
        local green=
        local red=
        local nocolor=
        ;;
  esac

  files=(${@:A})
  for file in $files; do
    if ! test -f $file; then
      echo >&2 "ztap: invalid file or file not found: '$file'"
      echo "Bail out!"
      return 1
    fi
  done

  echo TAP version 13
  for file in $files; do
    # run tests in a clean zsh subprocess
    HOME=$ZTAP_HOME/rcs \
    ZDOTDIR=$ZTAP_HOME/rcs \
    ZTAP_HOME=$ZTAP_HOME \
    ZTAP_TESTNUM=$ZTAP_TESTNUM_TOTAL \
    ZTAP_COLORIZE=$ZTAP_COLORIZE \
    zsh -d -l -c "test_runner \"$file\""

    # get the results variables form the test run
    if [[ ! -f $ZTAP_HOME/cache/${file:t} ]]; then
      echo 'Bail out!' 'Something went wrong and the test run results are unavailable'
    else
      source $ZTAP_HOME/cache/${file:t}
      command rm $ZTAP_HOME/cache/${file:t}
      (( ZTAP_TESTNUM_TOTAL = ZTAP_TESTNUM ))
      (( ZTAP_PASSED_TOTAL = ZTAP_PASSED_TOTAL + ZTAP_PASSED ))
      (( ZTAP_FAILED_TOTAL = ZTAP_FAILED_TOTAL + ZTAP_FAILED ))
    fi
  done

  echo
  echo "1..$ZTAP_TESTNUM_TOTAL"
  echo "${green}# pass $ZTAP_PASSED_TOTAL${nocolor}"
  test $ZTAP_FAILED_TOTAL -eq 0 &&
    echo "${green}# ok${nocolor}" ||
    echo "${red}# fail ${ZTAP_FAILED_TOTAL}${nocolor}"

  # return
  test $ZTAP_FAILED -eq 0
}
