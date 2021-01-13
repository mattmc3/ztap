function @echo() {
  echo "${TAPZ_CYAN}# ${@}${TAPZ_NOCOLOR}"
}

function @test() {
  local name="$1"; shift

  (( TAPZ_TESTNUM = TAPZ_TESTNUM + 1 ))

  if test $@; then
    (( TAPZ_PASSED = TAPZ_PASSED + 1 ))
    echo "${TAPZ_GREEN}ok ${TAPZ_TESTNUM} ${name}${TAPZ_NOCOLOR}"
  else
    (( TAPZ_FAILED = TAPZ_FAILED + 1 ))

    local operator expected actual
    if [[ -n $3 ]]; then
      operator=$2
      expected="${3:q}"
      actual="${1:q}"
    else
      operator=$1
      expected="${2:q}"
      actual="${__tapz_test_expectations[$1]:-unrecognized test operator: $operator}"
    fi

    echo "${TAPZ_RED}not ok ${TAPZ_TESTNUM} ${name}${TAPZ_NOCOLOR}"
    echo "  ---"
    echo "  operator: $operator"
    echo "  expected: $expected"
    echo "  actual: $actual"
    echo "  ..."
  fi
}

function test_runner() {
  filepath="$1"
  if [[ ! -f $filepath ]]; then
    echo "Bail out!" "File not found $filepath"
    return 1
  fi
  TAPZ_PASSED=0
  TAPZ_FAILED=0
  source $filepath
  mkdir -p $TAPZ_HOME/cache
  local resultfile=$TAPZ_HOME/cache/${filepath:t}
  echo "TAPZ_TESTNUM=${TAPZ_TESTNUM}" >| $resultfile
  echo "TAPZ_PASSED=${TAPZ_PASSED}" >> $resultfile
  echo "TAPZ_FAILED=${TAPZ_FAILED}" >> $resultfile
}

() {
  # setup variables
  autoload -U colors && colors
  typeset -Ag __tapz_test_expectations
  __tapz_test_expectations[-n]="did not find a non-zero length string"
  __tapz_test_expectations[-z]="did not find a zero length string"
  __tapz_test_expectations[-b]="did not find a block device"
  __tapz_test_expectations[-c]="did not find a character device"
  __tapz_test_expectations[-d]="did not find a directory"
  __tapz_test_expectations[-e]="did not find an existing file"
  __tapz_test_expectations[-f]="did not find a regular file"
  __tapz_test_expectations[-g]="did not find a file with the set-group-ID bit set"
  __tapz_test_expectations[-G]="did not find a file with same group ID as the current user"
  __tapz_test_expectations[-k]="did not find a file with the sticky bit set"
  __tapz_test_expectations[-L]="did not find a symbolic link"
  __tapz_test_expectations[-O]="did not find a file owned by the current user"
  __tapz_test_expectations[-p]="did not find a named pipe"
  __tapz_test_expectations[-r]="did not find a file marked as readable"
  __tapz_test_expectations[-s]="did not find a file of size greater than zero"
  __tapz_test_expectations[-S]="did not find a socket"
  __tapz_test_expectations[-t]="did not find a terminal tty file descriptor"
  __tapz_test_expectations[-u]="did not find a file with the set-user-ID bit set"
  __tapz_test_expectations[-w]="did not find a file marked as writable"
  __tapz_test_expectations[-x]="did not find a file marked as executable"
  TAPZ_TESTNUM=${TAPZ_TESTNUM:-0}
  TAPZ_COLORIZE=${TAPZ_COLORIZE:-false}
  if [[ $TAPZ_COLORIZE == true ]]; then
    TAPZ_CYAN=$fg[cyan]
    TAPZ_GREEN=$fg[green]
    TAPZ_RED=$fg[red]
    TAPZ_NOCOLOR=$reset_color
  fi
  TAPZ_PASSED=0
  TAPZ_FAILED=0
}
