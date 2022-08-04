#
# Set shell options and setup environment.
#

#region: Smart URLs
if ${TERM} != "dumb" ]]; then
  autoload -Uz bracketed-paste-url-magic
  zle -N bracketed-paste bracketed-paste-url-magic
  autoload -Uz url-quote-magic
  zle -N self-insert url-quote-magic
fi
#endregion

#region: Options
# general options
setopt COMBINING_CHARS       # combine zero-length punctuation characters (accents)
                             #   with the base character
setopt INTERACTIVE_COMMENTS  # enable comments in interactive shell
setopt RC_QUOTES             # allow 'Henry''s Garage' instead of 'Henry'\''s Garage'
unsetopt MAIL_WARNING        # don't print a warning message if a mail file has been accessed

# glob options
setopt EXTENDED_GLOB         # Treat the '#', '~' and '^' characters as part of patterns for filename generation
setopt GLOB_DOTS             # Do not require a leading '.' in a filename to be matched explicitly

# job options
setopt LONG_LIST_JOBS        # list jobs in the long format by default
setopt AUTO_RESUME           # attempt to resume existing job before creating a new process
setopt NOTIFY                # report status of background jobs immediately
unsetopt BG_NICE             # don't run all background jobs at a lower priority
unsetopt HUP                 # don't kill jobs on shell exit
unsetopt CHECK_JOBS          # don't report on jobs when shell exit
#endregion

#region: Aliases
alias type="type -a"
alias mkdir="mkdir -p"
GREP_EXCL=(.bzr CVS .git .hg .svn .idea .tox)
alias grep="${aliases[grep]:-grep} --exclude-dir={\${(j.,.)GREP_EXCL}}"

# macOS utils everywhere
if [[ "$OSTYPE" == darwin* ]]; then
  alias o='open'
elif [[ "$OSTYPE" == cygwin* ]]; then
  alias o='cygstart'
  alias pbcopy='tee > /dev/clipboard'
  alias pbpaste='cat /dev/clipboard'
elif [[ "$OSTYPE" == linux-android ]]; then
  alias o='termux-open'
  alias pbcopy='termux-clipboard-set'
  alias pbpaste='termux-clipboard-get'
else
  alias o='xdg-open'
  if [[ -n $DISPLAY ]]; then
    if (( $+commands[xclip] )); then
      alias pbcopy='xclip -selection clipboard -in'
      alias pbpaste='xclip -selection clipboard -out'
    elif (( $+commands[xsel] )); then
      alias pbcopy='xsel --clipboard --input'
      alias pbpaste='xsel --clipboard --output'
    fi
  else
    if (( $+commands[wl-copy] && $+commands[wl-paste] )); then
      alias pbcopy='wl-copy'
      alias pbpaste='wl-paste'
    fi
  fi
fi
#endregion

#region: Variables
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-$HOME/.xdg}

if [[ "$OSTYPE" == darwin* ]]; then
  export XDG_DESKTOP_DIR=${XDG_DESKTOP_DIR:-$HOME/Desktop}
  export XDG_DOCUMENTS_DIR=${XDG_DOCUMENTS_DIR:-$HOME/Documents}
  export XDG_DOWNLOAD_DIR=${XDG_DOWNLOAD_DIR:-$HOME/Downloads}
  export XDG_MUSIC_DIR=${XDG_MUSIC_DIR:-$HOME/Music}
  export XDG_PICTURES_DIR=${XDG_PICTURES_DIR:-$HOME/Pictures}
  export XDG_VIDEOS_DIR=${XDG_VIDEOS_DIR:-$HOME/Videos}
  export XDG_PROJECTS_DIR=${XDG_PROJECTS_DIR:-$HOME/Projects}
fi
#endregion

#region: Help
# Load more specific 'run-help' function from $fpath.
(( $+aliases[run-help] )) && unalias run-help && autoload -Uz run-help
#endregion
