@echo "=== strings ==="

@test "identical" foo = foo
@test "not identical" foo != bar
@test "non-zero-length" -n foo
@test "zero-length string" -z ""
