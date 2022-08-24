#!/usr/bin/env zsh
0=${(%):-%x}
source $ZTAP_HOME/ztap3.zsh
ztap_header "${0:t:r}"

() {
  @test "identical" foo = foo
}

() {
  @test "not identical" foo != bar
}

() {
  @test "non-zero-length" -n foo
}

() {
  @test "zero-length string" -z ""
}

() {
  local schrodingers_cat
  @test "zero-length var" -z "$schrodingers_cat"
}

() {
  local schrodingers_cat
  @test "not non-zero length" ! -n "$schrodingers_cat"
}

() {
  local schrodingers_cat=meow
  @test "not zero length var" -n $schrodingers_cat
}

ztap_footer
