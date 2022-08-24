#!/usr/bin/env zsh
0=${(%):-%x}
source $ZTAP_HOME/ztap3.zsh
ztap_header "${0:t:r}"

# setup
temp=$(command mktemp -d)

() {
  @test "an existing thing on the filesystem" -e $temp
}

() {
  @test "an existing directory" -d $temp
}

() {
  @test "a non-existing directory" ! -d "${temp}.fake"
}

() {
  @test "a regular file" $(command touch ${temp}/file) -f ${temp}/file
}

() {
  @test "a non-existing regular file" ! -f ${temp}/fake
}

() {
  @test "the file is empty" -z $(read <${temp}/file)
}

# cleanup
command rm -rf $temp

ztap_footer
