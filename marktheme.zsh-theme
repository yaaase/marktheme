function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
}
PR_GIT_UPDATE=1

setopt prompt_subst
autoload colors
colors

autoload -U add-zsh-hook
autoload -Uz vcs_info

if [[ $TERM = *255color* || $TERM = *rxvt* ]]; then
    turquoise="%F{81}"
    orange="%F{166}"
    purple="%F{135}"
    hotpink="%F{161}"
    limegreen="%F{118}"
else
    blue="$fg[blue]"
    turquoise="$fg[cyan]"
    orange="$fg[yellow]"
    purple="$fg[magenta]"
    hotpink="$fg[red]"
    limegreen="$fg[green]"
    yellow="$fg[yellow]"
    magenta="$fg[magenta]"
    black="$fg_bold[black]"
    white="$fg[white]"
fi

BRACKET_COLOR="%{$fg[yellow]%}"
RBENV_COLOR="%{$fg[green]%}"
if which rbenv &> /dev/null; then
  RBENV=" $BRACKET_COLOR"["$RBENV_COLOR${$(rbenv version | sed -e 's/ (set.*$//' -e 's/^ruby-//')}$BRACKET_COLOR"]"%{$reset_color%}"
fi

zstyle ':vcs_info:*' enable git svn

zstyle ':vcs_info:*:prompt:*' check-for-changes true
PR_RST="%{${reset_color}%}"
FMT_BRANCH=" (%{$turquoise%}%b%u%c${PR_RST})"
FMT_ACTION=" performing a %{$limegreen%}%a${PR_RST}"
FMT_UNSTAGED="%{$blue%}●"
FMT_STAGED="%{$limegreen%}●"

zstyle ':vcs_info:*:prompt:*' unstagedstr   "${FMT_UNSTAGED}"
zstyle ':vcs_info:*:prompt:*' stagedstr     "${FMT_STAGED}"
zstyle ':vcs_info:*:prompt:*' actionformats "${FMT_BRANCH}${FMT_ACTION}"
zstyle ':vcs_info:*:prompt:*' formats       "${FMT_BRANCH}"
zstyle ':vcs_info:*:prompt:*' nvcsformats   ""


function steeef_preexec {
    case "$(history $HISTCMD)" in
        *git*)
            PR_GIT_UPDATE=1
            ;;
        *svn*)
            PR_GIT_UPDATE=1
            ;;
    esac
}
add-zsh-hook preexec steeef_preexec

function steeef_chpwd {
    PR_GIT_UPDATE=1
}
add-zsh-hook chpwd steeef_chpwd

function steeef_precmd {
    if [[ -n "$PR_GIT_UPDATE" ]] ; then
        if [[ ! -z $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
            PR_GIT_UPDATE=1
            FMT_BRANCH="${PM_RST} %{$white%}(%{$reset_color%}%{$turquoise%}%b%u%c%{$hotpink%}●${PR_RST}%{$white%})%{$reset_color%}"
        else
            FMT_BRANCH="${PM_RST} %{$white%}(%{$turquoise%}%b%u%c${PR_RST}%{$white%})%{$reset_color%}"
        fi
        zstyle ':vcs_info:*:prompt:*' formats       "${FMT_BRANCH}"

        vcs_info 'prompt'
        PR_GIT_UPDATE=
    fi
}
add-zsh-hook precmd steeef_precmd
local ret_status="%(?:%{$fg_bold[green]%}»:%{$fg_bold[red]%}%s%?)"

PROMPT=$'
${ret_status}%{$reset_color%} %{$magenta%}%~%{$reset_color%}$RBENV$vcs_info_msg_0_%{$orange%} λ%{$reset_color%} '
