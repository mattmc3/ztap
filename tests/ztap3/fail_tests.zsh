#!/usr/bin/env zsh
0=${(%):-%x}
source $ZTAP_HOME/ztap3.zsh
ztap_header "${0:t:r}"

@test "success" "" = ""

unset nothingvar
@test "expecting nothing to be something!" -n "$nothingvar"
nothingvar=something
@test "now something should be nothing" -z "$nothingvar"

@test "infinite loop # TODO halting problem unsolved" -n ""
@test "infinite loop 2 # SKIP why run this?" -n ""

@test "success" "" = ""

ztap_footer
