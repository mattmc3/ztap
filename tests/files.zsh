@echo "=== files ==="

temp=$(command mktemp -d)

builtin cd $temp

@test "an existing thing on the filesystem" -e $temp
@test "an existing directory" -d $temp
@test "a regular file" $(command touch file) -f file
@test "the file is empty" -z $(read <file)

command rm -rf $temp
