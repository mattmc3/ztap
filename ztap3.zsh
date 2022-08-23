#!/usr/bin/env zsh
###
### ztap3
###
### An implementation of the Test Anything Protocol (https://testanything.org)
### for Zsh.
###
### Source: https://github.com/mattmc3/ztap
### License: MIT
### References https://testanything.org/tap-version-13-specification.html
###

() {
  0=${(%):-%x}
  ZTAP_VERSION=3.0.0
  ZTAP_HOME=${0:A:h}
  ZTAP_BIN=${0:A:h}/bin
  ZTAP_RUNID=$(date -u '+%Y%m%dT%H%M%SZ')
  ZTAP_DATESTAMP=$(date -u '+%Y-%m-%d %H:%M:%SZ')
  ZTAP_TESTNUM=${ZTAP_TESTNUM:-1}
  ZTAP_PASSED=0
  ZTAP_FAILED=0
  typeset -Ag ZTAP_OPERATORS=(
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
    ''     "value is non-empty"
  )
  ZTAP_ONEARG_TESTS=(-{b,c,d,e,f,g,h,k,n,p,r,s,t,u,w,x,z,L,O,G,S})
  ZTAP_TWOARG_TESTS=(-{nt,ot,e=f,eq,ne,gt,ge,lt,le} '=' '!=')
  if [[ -n "$XDG_CACHE_HOME" ]]; then
    ZTAP_CACHE_HOME=$XDG_CACHE_HOME/ztap
  else
    ZTAP_CACHE_HOME=$ZTAP_HOME/.cache
  fi
  mkdir -p "$ZTAP_CACHE_HOME"
}

function __ztap_scrub {
  1=${1//$'\t'/'\\t'}
  1=${1//$'\r'/'\\r'}
  1=${1//$'\n'/'\\n'}
  REPLY=$1
  echo $REPLY
}

function @echo {
  printf "# %s\n" "${(f)@}"
}

function @bailout {
  echo "Bail out!" "$@"
}

function @test {
  local REPLY description
  __ztap_scrub "$1" &>/dev/null; description=$REPLY; shift
  local test_result="ok ${ZTAP_TESTNUM} $description"
  (( ZTAP_TESTNUM = ZTAP_TESTNUM + 1 ))
  if test "$@"; then
    (( ZTAP_PASSED = ZTAP_PASSED + 1 ))
    echo $test_result
  else
    echo "not $test_result"
    if [[ $description = *"# TODO"* ]] ||
       [[ $description = *"# SKIP"* ]]
    then
      (( ZTAP_PASSED = ZTAP_PASSED + 1 ))
    else
      (( ZTAP_FAILED = ZTAP_FAILED + 1 ))
      __ztap_failure_yaml "$@"
      return 1
    fi
  fi
}

function __ztap_failure_yaml {
  local not notword
  if [[ $1 == "!" ]]; then
    not="!"; notword="*NOT* "; shift
  fi

  local oper values=()
  if [[ $# -eq 1 ]]; then
    values=("${(q-)1}")
  elif [[ $# -eq 2 ]] && [[ ${ZTAP_ONEARG_TESTS[(Ie)$1]} ]]; then
    oper=$1
    values=("${(q-)2}")
  elif [[ $# -eq 3 ]] && [[ ${ZTAP_TWOARG_TESTS[(Ie)$2]} ]]; then
    oper=$2
    values=("${(q-)1}" "${(q-)3}")
  fi

  echo "  ---"
  if (( $#values )); then
    local oper_desc="${notword}${ZTAP_OPERATORS[${oper}]}"
    echo "  operator: ${not}${oper} (${oper_desc})"
    local idx=0 val
    for val in "${values[@]}"; do
      (( idx = $idx + 1 ))
      echo "  value${idx}: $val"
    done
  else
    echo "  failed_test: ${(q-)@}"
  fi
  echo "  ..."
}

function ztap_header {
  echo "TAP version 13"
  echo "# ### ZTAP v3.0.0, test run $ZTAP_DATESTAMP ### #"
  [[ -n "$1" ]] && @echo "=== ${1} ==="
}

function ztap_footer {
  local total
  (( total = $ZTAP_PASSED + $ZTAP_FAILED ))
  echo ""
  echo "1..${total}"
  echo "# pass $ZTAP_PASSED"
  if [[ $ZTAP_FAILED -eq 0 ]]; then
    echo "# ok"
  else
    echo "# fail $ZTAP_FAILED"
    return 1
  fi
}

function ztap3 {
  local opts
  zparseopts -A opts -D -F -M -- c -color=c || return 1

  if [[ -v opts[-c] ]] || [[ -v opts[--color] ]]; then
    __ztap_chain "$@" | $ZTAP_BIN/colortap
    return $pipestatus[1]
  else
    __ztap_chain "$@"
    return $?
  fi
}

function __ztap_chain {
  local stderr errfile exitcode=0
  ZTAP_PASSED_TOTAL=0
  ZTAP_FAILED_TOTAL=0
  ZTAP_TESTNUM=1
  ztap_header

  for file in $@; do
    errfile="$ZTAP_CACHE_HOME/.ztap-${file:r:t}-stderr-${ZTAP_RUNID}.zsh"
    statefile="$ZTAP_CACHE_HOME/.ztap-${file:r:t}-state-${ZTAP_RUNID}.zsh"

    $file 2>$errfile | $ZTAP_BIN/chaintap -v testnum=$ZTAP_TESTNUM 3>$statefile
    [[ $pipestatus[1] -eq 0 ]] || exitcode=1

    stderr=$(<$errfile)
    if [[ -n "$stderr" ]]; then
      @echo "WARNING: tests wrote to stderr!"
      @echo "stderr: ${(q-)stderr}"
    fi

    source $statefile
    (( ZTAP_PASSED_TOTAL += ZTAP_PASSED ))
    (( ZTAP_FAILED_TOTAL += ZTAP_FAILED ))
    (( ZTAP_TESTNUM += ZTAP_PASSED + ZTAP_FAILED ))
  done

  ZTAP_PASSED=$ZTAP_PASSED_TOTAL
  ZTAP_FAILED=$ZTAP_FAILED_TOTAL
  ztap_footer

  # clean up
  for file in $ZTAP_CACHE_HOME/.ztap-*-${ZTAP_RUNID}(N); do
    rm -rf $file
  done

  return $exitcode
}
