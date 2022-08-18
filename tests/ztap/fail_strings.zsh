@echo "=== strings ==="

unset nothingvar
@test "expecting nothing to be something!" -n "$nothingvar"
nothingvar=something
@test "now something should be nothing" -z "$nothingvar"
