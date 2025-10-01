# .bashrc


# ================================= user-specific configs ========

export PATH=$PATH:/root/TG-VBC
export PATH=$PATH:/root/TG-VBC/actions
# ================================ Auto-completion script ============

_vbc_completion() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    local domains="vm cluster kubectl console"
    local vm_subs="create ping list ssh get-ip"
    local cluster_subs="create clean upload"
    local VM_LIST="$( get-vm -a 2>/dev/null )"     # dynamic VMs
    local NODE_LIST="$( get-vm -a master 2>/dev/null )"

    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$domains" -- "$cur") )
        return 0
    fi

    case "${COMP_WORDS[1]}" in
        vm)
            if [[ $COMP_CWORD -eq 2 ]]; then
                COMPREPLY=( $(compgen -W "$vm_subs" -- "$cur") )
                return 0
            fi
            case "${COMP_WORDS[2]}" in
                ping|get-ip)
                    COMPREPLY=( $(compgen -W "$VM_LIST" -- "$cur") )
                    ;;
                ssh)
                    if [[ "$cur" == -* ]]; then
                        COMPREPLY=( $(compgen -W "-r" -- "$cur") )
                    else
                        COMPREPLY=( $(compgen -W "$VM_LIST" -- "$cur") )
                    fi
                    ;;
            esac
            ;;
        cluster)
            if [[ $COMP_CWORD -eq 2 ]]; then
                COMPREPLY=( $(compgen -W "$cluster_subs" -- "$cur") )
                return 0
            fi

            if [[ "${COMP_WORDS[2]}" == "upload" ]]; then
                if [[ $COMP_CWORD -eq 3 ]]; then
                    # complete <node>
                    COMPREPLY=( $(compgen -W "$NODE_LIST" -- "$cur") )
                elif [[ $COMP_CWORD -eq 4 ]]; then
                    # complete <file>
                    COMPREPLY=( $(compgen -f -- "$cur") )
                fi
            fi
            ;;
        kubectl|console)
            COMPREPLY=()
            ;;
    esac
}
complete -F _vbc_completion vbc

complete -F _vbc_completion vbc

# =================================================================

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi



