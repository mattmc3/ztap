@echo "=== strings ==="

unset nothingvar
@test "this must fail" -n "$nothingvar"
