() {
  typeset -g ZTAP_HOME
  typeset -gax ZTAP_ONEARG_TESTS ZTAP_TWOARG_TESTS
  typeset -gAx ZTAP_TEST_DESCRIPTIONS

  ZTAP_HOME=${${(%):-%x}:A:h}
  ZTAP_ONEARG_TESTS=(-{b,c,d,e,f,g,h,k,n,p,r,s,t,u,w,x,z,L,O,G,S})
  ZTAP_TWOARG_TESTS=(-{nt,ot,ef,eq,ne,gt,ge,lt,le} '=' '!=')
  ZTAP_TEST_DESCRIPTIONS=(
    '-b'  "file exists and is a block special file"
    '-c'  "file exists and is a character special file"
    '-d'  "directory exists"
    '-e'  "file/directory exists (regardless of type)"
    '-f'  "regular file exists"
    '-g'  "file/directory exists and group ID flag is set"
    '-h'  "file/directory exists and is a symbolic link (do not rely on this, use -L)"
    '-k'  "file/directory exists and its sticky bit is set"
    '-n'  "length of string is nonzero"
    '-p'  "file is a named pipe (FIFO)"
    '-r'  "file/directory exists and is readable"
    '-s'  "file exists and has a size greater than zero"
    '-t'  "a terminal descriptor"
    '-u'  "file/directory exists and user ID flag is set"
    '-w'  "file/directory exists and is writable"
    '-x'  "file/directory exists and is executable"
    '-z'  "length of string is zero"
    '-L'  "file/directory exists and is a symbolic link"
    '-O'  "file/directory is owned by the current user"
    '-G'  "file/directory with same group ID as the current user"
    '-S'  "file exists and is a socket"
    '-nt'  "file1 exists and is newer than file2"
    '-ot'  "file1 exists and is older than file2"
    '-ef'  "file1 and file2 exist and refer to the same file"
    '-eq'  "integers n1 and n2 are algebraically equal"
    '-ne'  "integers n1 and n2 are not algebraically equal"
    '-gt'  "integer n1 is algebraically greater than the integer n2"
    '-ge'  "integer n1 is algebraically greater than or equal to the integer n2"
    '-lt'  "integer n1 is algebraically less than the integer n2"
    '-le'  "integer n1 is algebraically less than or equal to the integer n2"
    '='    "strings s1 and s2 are identical"
    '!='   "strings s1 and s2 are not identical"
  )
}

function @echo() {
  # TAP echo
  echo "# ${@}"
}

function @bailout() {
  # TAP 'Bail out!'
  echo "Bail out!" "${@}"
}

function @test() {
  # TAP test
  local name notsym notword
  name="$1"; shift

  (( ZTAP_TESTNUM = ZTAP_TESTNUM + 1 ))

  if test "$@"; then
    (( ZTAP_PASSED = ZTAP_PASSED + 1 ))
    echo "ok ${ZTAP_TESTNUM} ${name}"
  else
    (( ZTAP_FAILED = ZTAP_FAILED + 1 ))
    echo "not ok ${ZTAP_TESTNUM} ${name}"
    echo "  ---"
    if [[ $1 == "!" ]]; then
      notsym="! "
      notword="*not* "
      shift
    fi
    if [[ $# -eq 1 ]]; then
      echo "  operator: none (value is non-empty)"
      echo "  value: ${1:q}"
    elif [[ $# -eq 2 ]] && [[ ${ZTAP_ONEARG_TESTS[(Ie)$1]} ]]; then
      echo "  operator: ${notsym}$1 (${notword}${ZTAP_TEST_DESCRIPTIONS[$1]})"
      echo "  value: ${2:q}"
    elif [[ $# -eq 3 ]] && [[ ${ZTAP_TWOARG_TESTS[(Ie)$2]} ]]; then
      echo "  operator: ${notsym}$2 (${notword}${ZTAP_TEST_DESCRIPTIONS[$2]})"
      echo "  value1: ${1:q}"
      echo "  value2: ${3:q}"
    else
      echo "  test condition: ${notsym}${@}"
    fi
    echo "  ..."
    return 1
  fi
}

function run-test-file() {
  local errcode filepath resultfile
  filepath="$1"

  if ! [[ "$ZTAP_TESTNUM" -eq "$ZTAP_TESTNUM" ]]; then
    @bailout "run-test-file called directly. Use 'ztap' instead." && return 1
  elif [[ ! -f "$filepath" ]]; then
    @bailout "File not found '$filepath'." && return 1
  fi

  ZTAP_PASSED=0
  ZTAP_FAILED=0
  resultfile=$ZTAP_CACHE_DIR/${filepath:t}
  source "$filepath" 2>$resultfile.err

  # write out the results to pass data back from subshell
  echo "ZTAP_TESTNUM=${ZTAP_TESTNUM}" >| $resultfile
  echo "ZTAP_PASSED=${ZTAP_PASSED}" >> $resultfile
  echo "ZTAP_FAILED=${ZTAP_FAILED}" >> $resultfile
}

function ztap() {
  local ZTAP_CACHE_DIR=$ZTAP_HOME/.cache
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
  mkdir -p $ZTAP_CACHE_DIR

  case $1 in
    -v|--version)
        echo "ztap, version 2.0.0"
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

  if [[ $# -eq 0 ]]; then
    files=(./tests/*.zsh(N))
  else
    files=($@)
  fi

  if [[ ${#files[@]} -eq 0 ]]; then
    echo >&2 "ztap: no test files found"
    return 1
  fi
  for file in $files; do
    if [[ ! -f $file ]]; then
      echo >&2 "ztap: invalid file or file not found: '$file'"
      return 1
    fi
  done

  echo TAP version 13
  for file in $files; do
    # run tests in a clean zsh subprocess
    env -i \
    ZTAP_HOME=$ZTAP_HOME \
    ZTAP_CACHE_DIR=$ZTAP_CACHE_DIR \
    ZTAP_TESTNUM=$ZTAP_TESTNUM_TOTAL \
    TEST_FILE=$file \
    zsh --no-globalrcs --no-rcs --login -c 'source $ZTAP_HOME/ztap.zsh; run-test-file $TEST_FILE'

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
  [[ $ZTAP_FAILED_TOTAL -eq 0 ]]
}

function ztapc() {
  ztap "$@" | $ZTAP_HOME/bin/colorize_tap
}
