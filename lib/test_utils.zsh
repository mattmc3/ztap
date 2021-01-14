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
    if [[ $1 -eq "!" ]]; then
      operator="$1 $2"
      expected="${3:q}"
      actual="${__tapz_test_expectations[$2]:-unrecognized test operator: $operator}"
    elif [[ -n $3 ]]; then
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
  __tapz_test_expectations[-n]="a non-zero length string exists"
  __tapz_test_expectations[-z]="a zero length string exists"
  __tapz_test_expectations[-b]="a block device exists"
  __tapz_test_expectations[-c]="a character device exists"
  __tapz_test_expectations[-d]="a directory exists"
  __tapz_test_expectations[-e]="an existing file exists"
  __tapz_test_expectations[-f]="a regular file exists"
  __tapz_test_expectations[-g]="a file with the set-group-ID bit set exists"
  __tapz_test_expectations[-G]="a file with same group ID as the current user exists"
  __tapz_test_expectations[-k]="a file with the sticky bit set exists"
  __tapz_test_expectations[-L]="a symbolic link exists"
  __tapz_test_expectations[-O]="a file owned by the current user exists"
  __tapz_test_expectations[-p]="a named pipe exists"
  __tapz_test_expectations[-r]="a file marked as readable exists"
  __tapz_test_expectations[-s]="a file of size greater than zero exists"
  __tapz_test_expectations[-S]="a socket exists"
  __tapz_test_expectations[-t]="a terminal tty file descriptor exists"
  __tapz_test_expectations[-u]="a file with the set-user-ID bit set exists"
  __tapz_test_expectations[-w]="a file marked as writable exists"
  __tapz_test_expectations[-x]="a file marked as executable exists"
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
