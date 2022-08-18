@echo "=== strings ==="

@test "identical" foo = foo
@test "not identical" foo != bar
@test "non-zero-length" -n foo
@test "zero-length string" -z ""
@test "zero-length var" -z "$schrodingers_cat"
@test "not non-zero length" ! -n "$schrodingers_cat"
schrodingers_cat=meow
@test "not zero length var" -n $schrodingers_cat
#@test "a < b" a \< b
#@test "b > a" b \> a
