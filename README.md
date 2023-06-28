<h1 align="center">
    Ari's Dotfiles

[![CI][ci-shield]][ci-url] ![BASH Version][bash-version]
[![MIT License][license-shield]][license-url]

</h1>
<div id="top"></div>

<h5 align="center">Intended for Linux systems. Tested on Ubuntu 20.04, 21.10 and Fedora Workstation 36.</h5>

## About The Project

This project is a collection of dotfiles and scripts I use on my Linux systems.
It is intended to be used on Fedora/RHEL-based systems and in GitHub Codespaces.

## Installation

Run the following to install the dotfiles:

```sh
sh -c "$(curl -sL https://ceiphr.io/dotfiles/install)"
```

The installation script uses `git` to clone repository to `/tmp/dotfiles`. It
then runs the `bootstrap.sh` script to install all packages, create symlinks,
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

## TODO

-   [ ] Add `Ansible` playbook
-   [ ] Add documentation
-   [ ] Add screenshots

## License

Distributed under the MIT License. See
[LICENSE](https://github.com/ceiphr/dotfiles/blob/main/LICENSE) for more
information.

## Acknowledgments

I'm not going to take credit for all of this. I've taken heavy inspiration from
many other dotfiles repositories and projects. Here are some of them:

-   [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
-   [webpro/dotfiles](https://github.com/webpro/dotfiles)
-   [LukeSmithxyz/voidrice](https://github.com/LukeSmithxyz/voidrice)
-   [cowboy/dotfiles](https://github.com/cowboy/dotfiles)
-   [alrra/dotfiles](https://github.com/alrra/dotfiles)
-   [nicholastmosher/dotfiles](https://github.com/nicholastmosher/dotfiles)

If I've missed anyone, please let me know!

## Resources

-   [GNU Bash](https://www.gnu.org/software/bash/)
-   [Bash Automated Testing System](https://github.com/bats-core/bats-core)
-   [Oh My Zsh](https://ohmyz.sh/)
-   [xdg-ninja](https://github.com/b3nj5m1n/xdg-ninja)

<p align="right">(<a href="#top">back to top</a>)</p>

[bash-version]:
    https://img.shields.io/badge/bash-v4.4%5E-green?&logo=gnubash&logoColor=white
[ci-shield]:
    https://img.shields.io/github/actions/workflow/status/ceiphr/dotfiles/main.yml?logo=github
[ci-url]: https://github.com/ceiphr/dotfiles/actions/workflows/main.yml
[license-shield]: https://img.shields.io/github/license/ceiphr/dotfiles
[license-url]: https://github.com/ceiphr/dotfiles/blob/main/LICENSE
