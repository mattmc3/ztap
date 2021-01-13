() {
  typeset -gx TAPZ_HOME=${${(%):-%x}:A:h}
  autoload -U colors && colors
}

function tapz() {
  local TAPZ_TESTNUM=0
  local TAPZ_PASSED=0
  local TAPZ_FAILED=0
  local TAPZ_TESTNUM_TOTAL=0
  local TAPZ_PASSED_TOTAL=0
  local TAPZ_FAILED_TOTAL=0
  local TAPZ_COLORIZE=true
  local green=$fg[green]
  local red=$fg[red]
  local nocolor=$reset_color

  case $1 in
    -v|--version)
        echo "tapz, version 1.0.0"
        return
        ;;
    -h|--help)
        echo "Usage: tapz <files...>"
        echo "Options"
        echo "  -v --version    Print version"
        echo "  -h --help       Print this help message"
        echo "  -p --plaintext  Do not colorize output"
        return
        ;;
    -p|--plaintext)
        shift
        local TAPZ_COLORIZE=false
        local green=
        local red=
        local nocolor=
        ;;
  esac

  files=(${@:A})
  for file in $files; do
    if ! test -f $file; then
      echo >&2 "tapz: invalid file or file not found: '$file'"
      echo "Bail out!"
      return 1
    fi
  done

  echo TAP version 13
  for file in $files; do
    # run tests in a clean zsh subprocess
    HOME=$TAPZ_HOME/rcs \
    ZDOTDIR=$TAPZ_HOME/rcs \
    TAPZ_HOME=$TAPZ_HOME \
    TAPZ_TESTNUM=$TAPZ_TESTNUM_TOTAL \
    TAPZ_COLORIZE=$TAPZ_COLORIZE \
    zsh -d -l -c "test_runner \"$file\""

    # get the results variables form the test run
    if [[ ! -f $TAPZ_HOME/cache/${file:t} ]]; then
      echo 'Bail out!' 'Something went wrong and the test run results are unavailable'
    else
      source $TAPZ_HOME/cache/${file:t}
      command rm $TAPZ_HOME/cache/${file:t}
      (( TAPZ_TESTNUM_TOTAL = TAPZ_TESTNUM ))
      (( TAPZ_PASSED_TOTAL = TAPZ_PASSED_TOTAL + TAPZ_PASSED ))
      (( TAPZ_FAILED_TOTAL = TAPZ_FAILED_TOTAL + TAPZ_FAILED ))
    fi
  done

  echo
  echo "1..$TAPZ_TESTNUM_TOTAL"
  echo "${green}# pass $TAPZ_PASSED_TOTAL${nocolor}"
  test $TAPZ_FAILED_TOTAL -eq 0 &&
    echo "${green}# ok${nocolor}" ||
    echo "${red}# fail ${TAPZ_FAILED_TOTAL}${nocolor}"

  # return
  test $TAPZ_FAILED -eq 0
}
