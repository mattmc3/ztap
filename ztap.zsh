() {
  typeset -gx ZTAP_HOME=${${(%):-%x}:A:h}
}

function bailout() {
  # 'Bail out!' is a TAP term
  echo "Bail out!" $@
}

function ztap() {
  local ZTAP_TESTNUM=0
  local ZTAP_PASSED=0
  local ZTAP_FAILED=0
  local ZTAP_TESTNUM_TOTAL=0
  local ZTAP_PASSED_TOTAL=0
  local ZTAP_FAILED_TOTAL=0
  local ZTAP_WARNING_TOTAL=0
  local files file testresults
  typeset -a errors
  zmodload zsh/mapfile

  case $1 in
    -v|--version)
        echo "ztap, version 1.1.0"
        return
        ;;
    -h|--help)
        echo "Usage: ztap <files...>"
        echo "Options"
        echo "  -v --version    Print version"
        echo "  -h --help       Print this help message"
        echo "  -c --colorize   Colorize the TAP stream"
        return
        ;;
    -c|--colorize)
        shift
        ztapc "$@"
        return $?
        ;;
  esac

  files=(${@:A})
  for file in $files; do
    if ! test -f $file; then
      echo >&2 "ztap: invalid file or file not found: '$file'"
      bailout
      return 1
    fi
  done

  echo TAP version 13
  for file in $files; do
    # run tests in a clean zsh subprocess
    REAL_ZDOTDIR=${ZDOTDIR:-$HOME} \
    REAL_HOME=$HOME \
    HOME=$ZTAP_HOME/rcs \
    ZDOTDIR=$ZTAP_HOME/rcs \
    ZTAP_HOME=$ZTAP_HOME \
    ZTAP_TESTNUM=$ZTAP_TESTNUM_TOTAL \
    TEST_FILE=$file \
    zsh -d -l -c 'source $ZTAP_HOME/lib/ztap_init.zsh; run-test-file $TEST_FILE'

    # get the results variables from the test run
    testresults=$ZTAP_HOME/.cache/${file:t}

    if [[ -f $testresults.err ]]; then
      errors=(${(f)mapfile[$testresults.err]})
      command rm $testresults.err
      if [[ ${#errors[@]} -gt 0 ]]; then
        (( ZTAP_WARNING_TOTAL = ZTAP_WARNING_TOTAL + ${#errors[@]} ))
        echo "# WARNING: Test wrote to stderr. This may be an indicator of faulty tests."
        echo "# stderr: ${errors}"
      fi
    fi

    if [[ ! -f $testresults ]]; then
      bailout 'Something went wrong. The test results are unavailable.'
      return 1
    fi

    source $testresults
    command rm $testresults
    (( ZTAP_TESTNUM_TOTAL = ZTAP_TESTNUM ))
    (( ZTAP_PASSED_TOTAL = ZTAP_PASSED_TOTAL + ZTAP_PASSED ))
    (( ZTAP_FAILED_TOTAL = ZTAP_FAILED_TOTAL + ZTAP_FAILED ))
  done

  echo
  echo "1..$ZTAP_TESTNUM_TOTAL"
  echo "# pass $ZTAP_PASSED_TOTAL"
  [[ $ZTAP_WARNING_TOTAL -eq 0 ]] || echo "# warnings $ZTAP_WARNING_TOTAL"
  [[ $ZTAP_FAILED_TOTAL -eq 0 ]] &&
    echo "# ok" ||
    echo "# fail ${ZTAP_FAILED_TOTAL}"

  # return
  [[ $ZTAP_FAILED -eq 0 ]]
}

function ztapc() {
  ztap "$@" | $ZTAP_HOME/bin/colorize_tap
}
