function @echo() {
  echo "# ${@}"
}

function @test() {
  local name="$1"; shift

  (( ZTAP_TESTNUM = ZTAP_TESTNUM + 1 ))

  if test $@; then
    (( ZTAP_PASSED = ZTAP_PASSED + 1 ))
    echo "ok ${ZTAP_TESTNUM} ${name}"
  else
    (( ZTAP_FAILED = ZTAP_FAILED + 1 ))

    echo "not ok ${ZTAP_TESTNUM} ${name}"
    echo "  ---"
    local not notsym
    if [[ $1 == "!" ]]; then
      notsym="! "
      not="*not* "
      shift
    fi
    if [[ ${#@[@]} -eq 1 ]]; then
      echo "  description: test if string is not the null string"
      echo "  value: ${1:q}"
    elif [[ ${#@[@]} -eq 2 ]] && [[ ${__ztap_oneargtests[(Ie)$1]} ]]; then
      echo "  operator: ${notsym}$1 (${not}${__ztap_oneargtests[$1]})"
      echo "  value: ${2:q}"
    elif [[ ${#@[@]} -eq 3 ]] && [[ ${__ztap_comparisontests[(Ie)$2]} ]]; then
      echo "  value: ${1:q}"
      echo "  operator: ${notsym}$2 (${not}${__ztap_comparisontests[$2]})"
      echo "  comparison: ${3:q}"
    else
      echo "  test condition: ${notsym}${@}"
    fi
    echo "  ..."
  fi
}

function test_runner() {
  filepath="$1"
  if [[ ! -f $filepath ]]; then
    echo "Bail out!" "File not found $filepath"
    return 1
  fi
  ZTAP_PASSED=0
  ZTAP_FAILED=0
  source $filepath
  mkdir -p $ZTAP_HOME/cache
  local resultfile=$ZTAP_HOME/cache/${filepath:t}
  echo "ZTAP_TESTNUM=${ZTAP_TESTNUM}" >| $resultfile
  echo "ZTAP_PASSED=${ZTAP_PASSED}" >> $resultfile
  echo "ZTAP_FAILED=${ZTAP_FAILED}" >> $resultfile
}

() {
  # setup
  local o

  typeset -Ag __ztap_oneargtests
  __ztap_oneargtests[-b]="file exists and is a block special file"
  __ztap_oneargtests[-c]="file exists and is a character special file"
  __ztap_oneargtests[-d]="directory exists"
  __ztap_oneargtests[-e]="file/directory exists (regardless of type)"
  __ztap_oneargtests[-f]="regular file exists"
  __ztap_oneargtests[-g]="file/directory exists and group ID flag is set"
  __ztap_oneargtests[-h]="file/directory exists and is a symbolic link (do not rely on this, use -L)"
  __ztap_oneargtests[-k]="file/directory exists and its sticky bit is set"
  __ztap_oneargtests[-n]="length of string is nonzero"
  __ztap_oneargtests[-p]="file is a named pipe (FIFO)"
  __ztap_oneargtests[-r]="file/directory exists and is readable"
  __ztap_oneargtests[-s]="file exists and has a size greater than zero"
  __ztap_oneargtests[-t]="a terminal descriptor"
  __ztap_oneargtests[-u]="file/directory exists and user ID flag is set"
  __ztap_oneargtests[-w]="file/directory exists and is writable"
  __ztap_oneargtests[-x]="file/directory exists and is executable"
  __ztap_oneargtests[-z]="length of string is zero"
  __ztap_oneargtests[-L]="file/directory exists and is a symbolic link"
  __ztap_oneargtests[-O]="file/directory is owned by the current user"
  __ztap_oneargtests[-G]="file/directory with same group ID as the current user"
  __ztap_oneargtests[-S]="file exists and is a socket"

  typeset -Ag __ztap_comparisontests
  __ztap_comparisontests[-nt]="file1 exists and is newer than file2"
  __ztap_comparisontests[-ot]="file1 exists and is older than file2"
  __ztap_comparisontests[-ef]="file1 and file2 exist and refer to the same file"
  __ztap_comparisontests[=]="strings s1 and s2 are identical"
  __ztap_comparisontests[!=]="strings s1 and s2 are not identical"
  o="<"; __ztap_comparisontests[$o]="string s1 comes before s2 based on the binary value of their characters"
  o=">"; __ztap_comparisontests[$o]="string s1 comes after s2 based on the binary value of their characters"
  __ztap_comparisontests[-eq]="integers n1 and n2 are algebraically equal"
  __ztap_comparisontests[-ne]="integers n1 and n2 are not algebraically equal"
  __ztap_comparisontests[-gt]="integer n1 is algebraically greater than the integer n2"
  __ztap_comparisontests[-ge]="integer n1 is algebraically greater than or equal to the integer n2"
  __ztap_comparisontests[-lt]="integer n1 is algebraically less than the integer n2"
  __ztap_comparisontests[-le]="integer n1 is algebraically less than or equal to the integer n2"

  ZTAP_TESTNUM=${ZTAP_TESTNUM:-0}
  ZTAP_PASSED=0
  ZTAP_FAILED=0
}
