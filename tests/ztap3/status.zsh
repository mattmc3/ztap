#!/usr/bin/env zsh
0=${(%):-%x}
source $ZTAP_HOME/ztap3.zsh
ztap_header "${0:t:r}"

function return_this_status() {
  1=${1:-255}
  return $1
}

() {
  @test "true" $(true) $? -eq 0
}

() {
  @test "false" $(false) $? -eq 1
}

() {
  @test 255 `zsh -c "exit 255"` $? -eq 255
}

() {
  @test "return_this_status: 0" $(return_this_status 0) $? -eq 0
}

() {
  @test "return_this_status: 1" $(return_this_status 1) $? -eq 1
}

ztap_footer
