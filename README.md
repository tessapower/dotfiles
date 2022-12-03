# Tessa's Dotfiles

These are my dotfiles. They aren't intended to be useful to anyone other than myself. I have a Windows 11 machine and for development I use WSL with Ubuntu. 

## Organization

Files in the `common` directory are things I tend to use across multiple machines.

Files in the `personal` directory are organized by topic:

- **bin**: home-rolled shell scripts.
- **config**: things that are usually found in the `.config` dir.
- **git**: everything relating to git (aliases, configs, etc).
- **shell**: zsh and tmux configurations.
- **vim**: vim configuration and plugins.

## bootstrap.sh

The `bootstrap.sh` script will install the dotfiles in their respective
locations. Because altering your home directory is scary, `bootstrap.sh`
comes with a dry-run option (flag: `-d`).

### Configuration

The only part of the script which needs to be changed is the `FILES` array at
the start of `bootstrap.sh`. The `FILES` array contains a mapping of
every file in the repository and the location it should be linked to.

```sh
declare -a FILES=(
    'git/gitignore_global -> ~/.gitignore_global'
    'git/tigrc -> ~/.tigrc'
    'vim/vimrc -> ~/.vimrc'
    'shell/zshrc -> ~/.zshrc'
    'shell/tmux.conf -> ~/.tmux.conf'
    'tty/alacritty/alacritty.yml -> ~/.config/alacritty/alacritty.yml'
)
```

### Usage

```
Usage: ./bootstrap.sh [-h|--help] [-f] [-d] [-l]
    --help | -h
        Prints this menu
    -d
        Dry run. Echoes the commands which would be executed to
        stdout but doesn't modify anything.
    -f
        Force. Overwrites any existing files.
    -l
        Lists the files that would be installed by this program. Each
        full path is printed on a new line making the output suitable
        for piping to xargs or using as a for-loop input, i.e:

            for file in $(./bootstrap.sh -l); do
                ls -lah "$file";
            done
```

