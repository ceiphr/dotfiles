<h1 align="center">
    Ari's Dotfiles

[![CI][ci-shield]][ci-url] [![BASH Version][bash-version]][bash-url]
[![MIT License][license-shield]][license-url]

</h1>

<p align="center">Intended for Fedora/RHEL systems and GitHub Codespaces. Tested on Ubuntu 20.04, 21.10 and Fedora 36.</p>

## About The Project

This project is a collection of dotfiles and scripts I use on my Linux systems.
Depending on the system, it installs various packages from `apt`, `dnf`,
`flatpak`, `gnome-extensions`, `npm` and `pip`. It also creates symlinks for
various configuration files and directories from `src` to `$HOME` and will load
GNOME settings using `dconf` if the system is running GNOME.

The `extras` directory contains additional configuration files that are not
symlinked by default. These files are optional and can only be installed
manually.

## Installation

Run the following to install the dotfiles:

```sh
sh -c "$(curl -sL https://ceiphr.io/dotfiles/install)"
```

The installation script uses `git` to clone this repository to `/tmp/dotfiles`.
It then runs the `bootstrap.sh` script to install all packages, create symlinks,
and configure the system.

### Arguments

You can provide certain arguments to the installation script to customize the
installation process.

```sh
sh -c "$(curl -sL https://ceiphr.io/dotfiles/install)" -- [arguments]
```

Available arguments:

-   `--no-packages` - Skip installing packages
-   `--no-symlinks` - Skip creating symlinks
-   `--no-gnome` - Skip configuring GNOME
-   `--unattended` - Skip all prompts (useful for CI)

## Acknowledgments

I'm not going to take credit for all of this. I've taken heavy inspiration from
many other dotfiles repositories and projects. Here are some of them:

-   [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
-   [webpro/dotfiles](https://github.com/webpro/dotfiles)
-   [LukeSmithxyz/voidrice](https://github.com/LukeSmithxyz/voidrice)
-   [cowboy/dotfiles](https://github.com/cowboy/dotfiles)
-   [alrra/dotfiles](https://github.com/alrra/dotfiles)
-   [nicholastmosher/dotfiles](https://github.com/nicholastmosher/dotfiles)
-   [phanviet/vim-monokai-pro](https://github.com/phanviet/vim-monokai-pro)
-   [ceiphr/ee-framework-presets](https://github.com/ceiphr/ee-framework-presets)
-   [rafaelmardojai/firefox-gnome-theme](https://github.com/rafaelmardojai/firefox-gnome-theme)
-   [warningnonpotablewater/libinput-config](https://gitlab.com/warningnonpotablewater/libinput-config)

If I've missed anyone, please let me know!

## Resources

These are some of the resources I've used to build this project:

-   [GNU Bash](https://www.gnu.org/software/bash/)
-   [Bash Automated Testing System](https://github.com/bats-core/bats-core)
-   [Zsh](https://www.zsh.org/)
-   [pre-commit](https://pre-commit.com/)
-   [xdg-ninja](https://github.com/b3nj5m1n/xdg-ninja)

## License

Distributed under the MIT License. See
[LICENSE](https://github.com/ceiphr/dotfiles/blob/main/LICENSE) for more
information.

[bash-version]:
    https://img.shields.io/badge/bash-v4.4%5E-green?&logo=gnubash&logoColor=white
[bash-url]: https://packages.fedoraproject.org/pkgs/bash/bash/
[ci-shield]:
    https://img.shields.io/github/actions/workflow/status/ceiphr/dotfiles/main.yml?logo=github
[ci-url]: https://github.com/ceiphr/dotfiles/actions/workflows/main.yml
[license-shield]: https://img.shields.io/github/license/ceiphr/dotfiles
[license-url]: https://github.com/ceiphr/dotfiles/blob/main/LICENSE
