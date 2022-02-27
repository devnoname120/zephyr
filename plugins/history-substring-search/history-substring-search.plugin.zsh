#
# External
#

zephyr-clone-external history-substring-search zsh-users/zsh-history-substring-search
source ${0:A:h}/external/zsh-history-substring-search/zsh-history-substring-search.zsh

#
# Key Bindings
#

if [[ -n "$key_info" ]]; then
  # emacs
  bindkey -M emacs "$key_info[Control]P" history-substring-search-up
  bindkey -M emacs "$key_info[Control]N" history-substring-search-down

  # vi
  bindkey -M vicmd "k" history-substring-search-up
  bindkey -M vicmd "j" history-substring-search-down

  # emacs and vi
  for keymap in 'emacs' 'viins'; do
    bindkey -M "$keymap" "$key_info[Up]" history-substring-search-up
    bindkey -M "$keymap" "$key_info[Down]" history-substring-search-down
  done

  unset keymap
fi
