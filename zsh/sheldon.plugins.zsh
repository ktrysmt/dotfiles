# `sheldon` configuration file
# ----------------------------
#
# You can modify this file directly or you can use one of the following
# `sheldon` commands which are provided to assist in editing the config file:
#
# - `sheldon add` to add a new plugin to the config file
# - `sheldon edit` to open up the config file in the default editor
# - `sheldon remove` to remove a plugin from the config file
#
# See the documentation for more https://github.com/rossmacarthur/sheldon#readme

shell = "zsh"

apply = ["defer"]

[templates]
defer = { value = 'zsh-defer source "{{ file }}"', each = true }

[plugins.zsh-defer]
github = "romkatv/zsh-defer"
apply = ["source"]

[plugins.compinit]
inline = 'autoload -Uz compinit && zsh-defer compinit'

[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"

[plugins.zsh-completions]
github = "zsh-users/zsh-completions"

[plugins.ohmyzsh]
github = "ohmyzsh/ohmyzsh"
dir = "lib"
use = ["{completion,key-bindings,directories}.zsh"]

[plugins.asdf]
github = "asdf-vm/asdf"

[plugins.zsh-better-npm-completion]
github = "lukechilds/zsh-better-npm-completion"

[plugins.aws_zsh_completer]
remote = "https://github.com/aws/aws-cli/blob/v2/bin/aws_zsh_completer.sh"

[plugins.dotfiles-source]
local = "~/dotfiles/zsh"
use = ["{color,sync}.zsh"]
apply = ["source"]

[plugins.dotfiles-defer]
local = "~/dotfiles/zsh"
use = ["{!color,!sync,*}.zsh"]

