#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/bats-file/load'

    DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
    PATH="$DIR/..:$PATH"
    DIRECTORY=$HOME
}

@test "Standard dotfiles bootstrap." {
    run bootstrap.sh --no-packages --unattended
    [ "$status" -eq 0 ]

    assert_output --partial "Syncing dotfiles..."
    assert_output --partial "Done."

    run zsh -c "source $DIRECTORY/.zshrc"
    [ "$status" -eq 0 ]
}

@test "Remote dotfiles install." {
    run remote-install.sh --no-packages --unattended
    [ "$status" -eq 0 ]

    assert_output --partial "Installing dotfiles..."
    if [[ "$CI" ]]; then
        assert_dir_exists "$DIRECTORY/.dotfiles"
    else
        assert_dir_exists "/tmp/dotfiles"
    fi

    run zsh -c "source $DIRECTORY/.zshrc"
    [ "$status" -eq 0 ]
}

teardown() {
    if [ -d "/tmp/dotfiles" ]; then
        rm -rf "/tmp/dotfiles"
    fi

    if [ -d "$DIRECTORY/.dotfiles" ]; then
        rm -rf "$DIRECTORY/.dotfiles"
    fi
}
