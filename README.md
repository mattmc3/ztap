# ZTAP

[![MIT License](https://img.shields.io/badge/license-MIT-007EC7.svg)](/LICENSE)

> An implementation of the [Test Anything Protocol][tap] for unit testing Zsh scripts
using pure Zsh

ZTAP allows you to test your Zsh scripts using pure Zsh. Use it to test anything:
scripts, functions, plugins, whatever - all without leaving Zsh.

Here's an example to get you started:

```zsh
@test "zsh has a place to call home" -d ${ZDOTDIR:-$HOME}

@test "the answer to life, the universe, and everything" $(( 6 * 7 )) -eq 42

@test "got root?" $USER = root
```

Now put that in a `.zsh` file and run it with `ztap` installed.
Behold, the TAP stream!

```console
TAP version 13
ok 1 zsh has a place to call home
ok 2 the answer to life, the universe, and everything
not ok 3 got root?
  ---
  operator: = (strings s1 and s2 are identical)
  value1: mattmc3
  value2: root
  ...

1..3
# pass 2
# fail 1
```

Each test file runs inside its own subshell, so you can modify the global environment
without cluttering your session or breaking other tests. If all the tests pass, `ztap`
exits with a return code of `0`, or `1` otherwise.

## Installation

Install with a plugin manager:

- [antidote][antidote]: `antidote bundle mattmc3/ztap`

Install manually:

```zsh
# clone the repo
git clone --depth 1 https://github.com/mattmc3/ztap ~/.config/zsh/plugins/ztap

# source ztap in your .zshrc
source ~/.config/zsh/plugins/ztap/ztap3.zsh
```

## Writing Tests

Tests are defined with the `@test` function. Each test begins with a description,
followed by a typical `test` expression. Refer to the `test` builtin
[documentation](http://zsh.sourceforge.net/Doc/Release/Conditional-Expressions.html) for
operators and usage details.

```zsh
@test <description> [<expected>] <operator> <actual>
```

### Handling setup/teardown

Often you have work that needs to happen before and after tests run like preparing the
environment and cleaning up after you're done. The best way to do this is directly in
your test file. Your tests are all written in Zsh, after all.

```zsh
# setup
tmp=$(mktemp -d)

# run tests
() {
  @test "file doesn't exist yet" ! -f $tmp/testfile
  touch $tmp/testfile
  @test "a file now exists" -f $tmp/testfile
}

# teardown
rm -rf $tmp
```

For more advanced setup/teardown operations, you may consider sourcing a common include
file, or even writing reusable functions for setup/teardown operations.

### Handling multiline output

When comparing multiline output you have a few options including

- collapse newlines using `echo`
- collect your input into an array

```zsh
# You can use echo to collapse
@test "2,4,6,8! Who do we appreciate?" "$(echo $(seq 2 2 8))" = "2 4 6 8"

# collect output to a zsh array
arr=($(seq 10 1))
@test "Countdown!" "${arr[*]}" = "10 9 8 7 6 5 4 3 2 1"
```

If you want to write to stdout while tests are running, use the `@echo` function.
It's equivalent to `echo "# $argv"`, which prints a TAP comment.

```zsh
@echo "=== example ==="
```

### Handling stderr

Output to stderr is considered a warning by ZTAP. It could be an indicator of a syntax
error in your tests, or it could be a normal part of the utility you are testing. It's
best to always redirect stderr output and explicitly test for it.

```zsh
# redirect stderr to stdout for success
output=($(source myutility.zsh 2>&1))

# test output is expected
expected="it's alive!"
@test "Is it alive?" "$expected" = "$output"
```

## Using ZTAP in your Zsh project

If you are building a Zsh project and would like to use ZTAP to run tests for that
project, it can be helpful to include a simple test runner script. I recommend putting
a simple script in your project's `./bin/runtests` file:

```zsh
#!/usr/bin/env zsh
[[ -d .ztap ]] || git clone --depth 1 -q https://github.com/mattmc3/ztap.git .ztap
source ./.ztap/ztap.zsh
ztap $@
```

If you want something slightly more robust, use the following script:

```zsh
#!/usr/bin/env zsh
# contents of ./tools/runtests in your project

0=${(%):-%N}
PROJECT_HOME=${0:A:h:h}
export ZTAP_HOME=${ZTAP_HOME:-$PROJECT_HOME/.ztap}

[[ -d $ZTAP_HOME ]] ||
  git clone --depth 1 -q https://github.com/mattmc3/ztap $ZTAP_HOME

source $ZTAP_HOME/ztap3.zsh
if (( $# )); then
  ztap3 -c "$@"
else
  ztap3 -c $PROJECT_HOME/tests/*.zsh
fi
```

Don't forget to make your `./bin/runtests` file executable:

```zsh
chmod 755 ./bin/runtests
```

Also, be sure to add `.ztap/` to your `.gitignore` so that you don't check ZTAP into
your repo unintentionally.

[tap]: https://testanything.org
[antidote]: https://github.com/mattmc3/antidote
