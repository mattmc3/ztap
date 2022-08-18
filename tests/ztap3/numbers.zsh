#!/usr/bin/env zsh
0=${(%):-%x}
BASEDIR=${0:A:h:h:h}

source $BASEDIR/ztap3.zsh
ztap_header "${0:t:r}"

() {
  @test "numerically equal" 1 -eq 1
}

() {
  @test "not numerically equal" 0 -ne 1
}

() {
  @test "greater than" 2 -gt 1
}

() {
  @test "greater than or equal" 2 -ge 2
}

() {
  @test "less than" 1 -lt 2
}

() {
  @test "less than or equal" 2 -le 2
}

() {
  local dadams=42
  @test "meaning of life the universe and everything" $dadams -eq 42
}

ztap_footer
