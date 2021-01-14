@test "fail equals 1 -eq 2" 1 -eq 2
@test "fail home directory" ! -d $HOME
@test "fail file exists" -f $HOME/foo/bar/baz/fake
@test "fail syntax single arg test" -foo bar
@test "fail syntax  comparison test" foo -bar baz
@test "fail not even an actual test" instant gratification takes too long
@test "fail wow such empty"
