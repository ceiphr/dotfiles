#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/bats-file/load'

    DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
    PATH="$DIR/..:$PATH"
    DIRECTORY=$HOME
}

@test "Standard dotfiles install." {
    run bootstrap.sh -f
    [ "$status" -eq 0 ]

    assert_output --partial "Syncing dotfiles..."
    assert_output --partial "Done."

    run zsh -c "source ~/.zshrc"
    [ "$status" -eq 0 ]
}

@test "Remote dotfiles install." {
    run sh -c "$(curl -sL https://ceiphr.io/dotfiles/install)" -- -f
    [ "$status" -eq 0 ]

    assert_output --partial "Syncing dotfiles..."
    assert_output --partial "Done."
    assert_exists "/tmp/dotfiles"

    run zsh -c "source ~/.zshrc"
    [ "$status" -eq 0 ]
}
