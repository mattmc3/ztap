#!/usr/bin/env zsh
0=${(%):-%x}
BASEDIR=${0:A:h:h:h}

source $BASEDIR/ztap3.zsh
ztap_header "${0:t:r}"

@test "success" "" = ""

unset nothingvar
@test "expecting nothing to be something!" -n "$nothingvar"
nothingvar=something
@test "now something should be nothing" -z "$nothingvar"

@test "success" "" = ""

ztap_footer
