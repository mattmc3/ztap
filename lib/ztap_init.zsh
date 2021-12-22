function @echo() {
  echo "# ${@}"
}

function @bailout() {
  echo "Bail out!" "${@}"
}

function @test() {
  local name="$1"; shift

  (( ZTAP_TESTNUM = ZTAP_TESTNUM + 1 ))

  if [[ $@ ]]; then
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
      echo "        value: ${1:q}"
    elif [[ ${#@[@]} -eq 2 ]] && [[ ${_ztap_oneargtests[(Ie)$1]} ]]; then
      echo "  operator: ${notsym}$1 (${not}${_ztap_oneargtests[$1]})"
      echo "     value: ${2:q}"
    elif [[ ${#@[@]} -eq 3 ]] && [[ ${_ztap_comparisontests[(Ie)$2]} ]]; then
      echo "      value: ${1:q}"
      echo "   operator: ${notsym}$2 (${not}${_ztap_comparisontests[$2]})"
      echo " comparison: ${3:q}"
    else
      echo "  test condition: ${notsym}${@}"
    fi
    echo "  ..."
  fi
}

function run-test-file() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_CONTINUE_ON_ERROR
  set -e

  local errcode filepath
  filepath="$1"
  if [[ ! -f "$filepath" ]]; then
    @bailout "File not found '$filepath'." && return 1
  fi
  ZTAP_PASSED=0
  ZTAP_FAILED=0
  mkdir -p $ZTAP_HOME/.cache
  local resultfile=$ZTAP_HOME/.cache/${filepath:t}
  source "$filepath" 2>$resultfile.err
  echo "ZTAP_TESTNUM=${ZTAP_TESTNUM}" >| $resultfile
  echo "ZTAP_PASSED=${ZTAP_PASSED}" >> $resultfile
  echo "ZTAP_FAILED=${ZTAP_FAILED}" >> $resultfile
}

() {
  # setup
  typeset -Ag _ztap_oneargtests
  _ztap_oneargtests=(
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
  )

  typeset -Ag _ztap_comparisontests
  _ztap_comparisontests=(
    '-nt'  "file1 exists and is newer than file2"
    '-ot'  "file1 exists and is older than file2"
    '-ef'  "file1 and file2 exist and refer to the same file"
    '='    "strings s1 and s2 are identical"
    '!='   "strings s1 and s2 are not identical"
    '<'    "string s1 comes before s2 based on the binary value of their characters"
    '>'    "string s1 comes after s2 based on the binary value of their characters"
    '-eq'  "integers n1 and n2 are algebraically equal"
    '-ne'  "integers n1 and n2 are not algebraically equal"
    '-gt'  "integer n1 is algebraically greater than the integer n2"
    '-ge'  "integer n1 is algebraically greater than or equal to the integer n2"
    '-lt'  "integer n1 is algebraically less than the integer n2"
    '-le'  "integer n1 is algebraically less than or equal to the integer n2"
  )
  ZTAP_TESTNUM=${ZTAP_TESTNUM:-0}
  ZTAP_PASSED=0
  ZTAP_FAILED=0
}
