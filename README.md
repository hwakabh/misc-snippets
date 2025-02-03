# gists
Collections of code snippets in [GitHub Gist](https://gist.github.com/hwakabh) with git-subomodule.

## Caveat
Currently there is no functionalities to automatically sync changes of submodules in [Gist](https://gist.github.com).
So the following operation will be required when we change snippets in Gist for manually applying changes into this repository.

```shell
# Fetch latest changes from Gists side into this repository
% git submodule update --remote

% git add .
% git commit -m "chore: updated submodules"
% git push
```

Note that these operations requires to clone this repo recursively, whereas by default `git clone` does not do this.
```shell
% git clone --recursive git@github.com:hwakabh/gists.git
% git fetch --all --prune --recurse-submodules=yes
```
