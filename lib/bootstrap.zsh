#
# bootstrap: Ensure Zephyr is properly boostrapped.
#

# Set common vars.
0=${(%):-%N}
ZEPHYR_HOME=${0:a:h:h}

# Critical Zsh options
setopt extended_glob interactive_comments

# Set Zsh locations.
typeset -gx __zsh_{config,cache,user_data}_dir
if [[ -z "$__zsh_config_dir" ]]; then
  zstyle -s ':zephyr:xdg:config' dir '__zsh_config_dir' \
    || __zsh_config_dir=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}
  __zsh_config_dir=${~__zsh_config_dir}
fi
if [[ -z "$__zsh_user_data_dir" ]]; then
  zstyle -s ':zephyr:xdg:user_data' dir '__zsh_user_data_dir' \
    || __zsh_user_data_dir=${XDG_DATA_HOME:-$HOME/.local/share}/zsh
  __zsh_user_data_dir=${~__zsh_user_data_dir}
fi
if [[ -z "$__zsh_cache_dir" ]]; then
  zstyle -s ':zephyr:xdg:cache' dir '__zsh_cache_dir' \
    || __zsh_cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
  __zsh_cache_dir=${~__zsh_cache_dir}
fi

# Support for hooks.
autoload -Uz add-zsh-hook

##? Make directories from vars
function mkdir-fromvar {
  local zdirvar
  for zdirvar in $@; do
    [[ -d ${(P)zdirvar} ]] || mkdir -p ${(P)zdirvar}
  done
}
mkdir-fromvar __zsh_{config,cache,user_data}_dir

##? Autoload a user functions directory.
function autoload-dir {
  local fndir funcfiles=()
  for fndir in $@; do
    [[ -d $fndir ]] || return 1
    fpath=($fndir $fpath)
    funcfiles=($fndir/*~*/_*(N.:t))
    (( ${#funcfiles} > 0 )) && autoload -Uz $funcfiles
  done
}

##? Memoize a command
function cached-command {
  emulate -L zsh; setopt local_options extended_glob
  (( $# >= 2 )) || return 1

  # make the command name safer as a file path
  local cmdname="${1}"; shift
  cmdname=${cmdname:gs/\@/-AT-}
  cmdname=${cmdname:gs/\:/-COLON-}
  cmdname=${cmdname:gs/\//-SLASH-}

  local memofile=$__zsh_cache_dir/memoized/${cmdname}.zsh
  local -a cached=($memofile(Nmh-20))
  if ! (( ${#cached} )); then
    mkdir -p ${memofile:h}
    "$@" 2>/dev/null >$memofile
  fi
  source $memofile
}

##? Check if a file can be autoloaded by trying to load it in a subshell.
function is-autoloadable {
  ( unfunction $1 ; autoload -U +X $1 ) &> /dev/null
}

##? Check if a name is a command, function, or alias.
function is-callable {
  (( $+commands[$1] || $+functions[$1] || $+aliases[$1] || $+builtins[$1] ))
}

##? Check a string for case-insensitive "true" value (1,y,yes,t,true,o,on).
function is-true {
  [[ -n "$1" && "$1:l" == (1|y(es|)|t(rue|)|o(n|)) ]]
}

##? Check if running on macOS.
function is-macos {
  [[ "$OSTYPE" == darwin* ]]
}

##? Check if running on Linux.
function is-linux {
  [[ "$OSTYPE" == linux* ]]
}

##? Check if running on BSD.
function is-bsd {
  [[ "$OSTYPE" == *bsd* ]]
}

##? Check if running on Cygwin (Windows).
function is-cygwin {
  [[ "$OSTYPE" == cygwin* ]]
}

##? Check if running on termux (Android).
function is-termux {
  [[ "$OSTYPE" == linux-android ]]
}

# Mark this lib as loaded.
zstyle ":zephyr:lib:bootstrap" loaded 'yes'
