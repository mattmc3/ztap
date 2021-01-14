function @echo() {
  echoc cyan "# ${@}"
}

function @test() {
  local name="$1"; shift

  (( TAPZ_TESTNUM = TAPZ_TESTNUM + 1 ))

  if test $@; then
    (( TAPZ_PASSED = TAPZ_PASSED + 1 ))
    echoc green "ok ${TAPZ_TESTNUM} ${name}"
  else
    (( TAPZ_FAILED = TAPZ_FAILED + 1 ))

    echoc red "not ok ${TAPZ_TESTNUM} ${name}"
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
    elif [[ ${#@[@]} -eq 2 ]] && [[ ${__tapz_oneargtests[(Ie)$1]} ]]; then
      echo "  operator: ${notsym}$1 (${not}${__tapz_oneargtests[$1]})"
      echo "  value: ${2:q}"
    elif [[ ${#@[@]} -eq 3 ]] && [[ ${__tapz_comparisontests[(Ie)$2]} ]]; then
      echo "  value: ${1:q}"
      echo "  operator: ${notsym}$2 (${not}${__tapz_comparisontests[$2]})"
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
  TAPZ_PASSED=0
  TAPZ_FAILED=0
  source $filepath
  mkdir -p $TAPZ_HOME/cache
  local resultfile=$TAPZ_HOME/cache/${filepath:t}
  echo "TAPZ_TESTNUM=${TAPZ_TESTNUM}" >| $resultfile
  echo "TAPZ_PASSED=${TAPZ_PASSED}" >> $resultfile
  echo "TAPZ_FAILED=${TAPZ_FAILED}" >> $resultfile
}

function echoc() {
  local a z
  if [[ -n $fg[$1] ]]; then
    if [[ $TAPZ_COLORIZE == true ]]; then
      a=$fg[$1]
      z=$reset_color
    fi
    shift
  fi
  echo "${a}${@}${z}"
}

() {
  # setup
  local o
  autoload -U colors && colors

  typeset -Ag __tapz_oneargtests
  __tapz_oneargtests[-b]="file exists and is a block special file"
  __tapz_oneargtests[-c]="file exists and is a character special file"
  __tapz_oneargtests[-d]="directory exists"
  __tapz_oneargtests[-e]="file/directory exists (regardless of type)"
  __tapz_oneargtests[-f]="regular file exists"
  __tapz_oneargtests[-g]="file/directory exists and group ID flag is set"
  __tapz_oneargtests[-h]="file/directory exists and is a symbolic link (do not rely on this, use -L)"
  __tapz_oneargtests[-k]="file/directory exists and its sticky bit is set"
  __tapz_oneargtests[-n]="length of string is nonzero"
  __tapz_oneargtests[-p]="file is a named pipe (FIFO)"
  __tapz_oneargtests[-r]="file/directory exists and is readable"
  __tapz_oneargtests[-s]="file exists and has a size greater than zero"
  __tapz_oneargtests[-t]="a terminal descriptor"
  __tapz_oneargtests[-u]="file/directory exists and user ID flag is set"
  __tapz_oneargtests[-w]="file/directory exists and is writable"
  __tapz_oneargtests[-x]="file/directory exists and is executable"
  __tapz_oneargtests[-z]="length of string is zero"
  __tapz_oneargtests[-L]="file/directory exists and is a symbolic link"
  __tapz_oneargtests[-O]="file/directory is owned by the current user"
  __tapz_oneargtests[-G]="file/directory with same group ID as the current user"
  __tapz_oneargtests[-S]="file exists and is a socket"

  typeset -Ag __tapz_comparisontests
  __tapz_comparisontests[-nt]="file1 exists and is newer than file2"
  __tapz_comparisontests[-ot]="file1 exists and is older than file2"
  __tapz_comparisontests[-ef]="file1 and file2 exist and refer to the same file"
  __tapz_comparisontests[=]="strings s1 and s2 are identical"
  __tapz_comparisontests[!=]="strings s1 and s2 are not identical"
  o="<"; __tapz_comparisontests[$o]="string s1 comes before s2 based on the binary value of their characters"
  o=">"; __tapz_comparisontests[$o]="string s1 comes after s2 based on the binary value of their characters"
  __tapz_comparisontests[-eq]="integers n1 and n2 are algebraically equal"
  __tapz_comparisontests[-ne]="integers n1 and n2 are not algebraically equal"
  __tapz_comparisontests[-gt]="integer n1 is algebraically greater than the integer n2"
  __tapz_comparisontests[-ge]="integer n1 is algebraically greater than or equal to the integer n2"
  __tapz_comparisontests[-lt]="integer n1 is algebraically less than the integer n2"
  __tapz_comparisontests[-le]="integer n1 is algebraically less than or equal to the integer n2"

  TAPZ_TESTNUM=${TAPZ_TESTNUM:-0}
  TAPZ_COLORIZE=${TAPZ_COLORIZE:-false}
  TAPZ_PASSED=0
  TAPZ_FAILED=0
}
