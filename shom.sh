

SHOM_URL_SRC="https://github.com/Brodylive/ShowMe.git"
SHOM_PATH="$HOME/.shom"
SHOM_SCRIPT="$SHOM_PATH/bin/shom"


##################################################################
# Installation procedure
if [[ ! -f "$SHOM_SCRIPT" ]]; then
    if [[ ! -d "$SHOM_PATH" ]]; then
        mkdir -p ${SHOM_PATH}
    fi
        cd ${SHOM_PATH}

    if [[ $(basename $0) != "shom" ]]; then
        echo -en "\n\t \033[0;1;33m Downloading sources \033[0m"
        git clone ${SHOM_URL_SRC} .
        echo -e "\t[✓]"
    fi
fi

# Add to profile
for FILE in $HOME/.profile $HOME/.bash_profile $HOME/.bashrc; do
    if [[ -f ${FILE} ]]; then
        if [[ $(grep -s "$SHOM_PATH" ${FILE}) ]]; then
            unset FILE; break
        fi
    fi
done

if [[ -f ${FILE} ]]; then
    echo -en "\n\t \033[0;1;33m Add ShowMe to your $FILE \033[0m"
    echo "source $SHOM_SCRIPT" >> ${FILE}
    echo "alias l=shom" >> ${FILE}
    echo -e "\t[✓]"
    source ${FILE}
    return 0
fi



##################################################################
# MODULES

function updateGit() {
    shom
    pushd . &>/dev/null
    echo -e "\n $DARK_GRAY Changing directory $NONE"
    cd $SHOM_PATH
    echo -e "\n $DARK_GRAY Pulling sources $NONE"
    pull
    echo -e "\n $DARK_GRAY Pop to previous directory $NONE"
    popd &>/dev/null
}

function color_shom(){
    RED="\033[0;31m"
    YELLOW="\033[0;1;33m"
    BROWN="\033[1;2;33m"
    LIGHT_CYAN="\033[0;1;36m"
    LIGHT_BROWN="\033[0;33m"
    NONE="\033[0m"
    UNDERLINE="\033[4m"
}

function help_shom(){
    color_shom
    echo -e "$YELLOW  Usage : $LIGHT_BROWN shom [-r] [<option>:<value>] $NONE"
    echo -e "\n\t $LIGHT_BROWN ${UNDERLINE}Options$NONE\n"
    echo -e "\t $YELLOW s:$LIGHT_BROWN<string> \t$BROWN Grep a string $NONE"
    echo -e "\t $YELLOW p:$LIGHT_BROWN<path> \t$BROWN Search in/from specific folder $NONE"
    echo -e "\t $YELLOW e:$LIGHT_BROWN<extension> $BROWN Search only within this extension file $NONE\n"
    echo -e "\t $YELLOW -r  \t\t$BROWN Recursive research without permissions display $NONE\n"
    echo -e "\n  Made with ❤︎ $LIGHT_CYAN by Jenn Brody$NONE"
}

function error_shom(){
    echo -e " ${RED} Nothing found ${NONE}"
}

function shom(){
    color_shom
    echo -en "\n $YELLOW${UNDERLINE} Show${LIGHT_BROWN}${UNDERLINE}Me  ${YELLOW}${UNDERLINE}|"
    echo -e "${LIGHT_BROWN}${UNDERLINE}  $(pwd) $NONE\n"
    
    # shom without args
    if [[ -z "$1" ]]; then
        ls -Glah
    else

        # Process args
        recursive=0
        for arg in "$@"
        do
            opt=${arg%:*}
            var=${arg#*:}

            case ${opt} in 
                e )
                    ext=${var}
                    ;;
                s )
                    search=${var}
                    ;;
                p )
                    path=${var}
                    ;;
                -r )
                    recursive=1
                    ;;
                * )
                    help_shom
                    return 0
            esac
        done
        
        # ARGS display
        echo -e "  🎯 ${LIGHT_BROWN} ${search:+%}${search:-*}${search:+%}${BROWN}.${ext:-*} $YELLOW ${path} $NONE\n\n"

        # FIND -> Recursive
        if [[ $recursive -eq 1 ]]; then
            set -- find
            if [[ -z "${path}" ]]; then
                set -- "$@" .
            else
                set -- "$@" "${path}"
            fi

            if [[ -n "${ext}" ]]; then
                set -- "$@" -iname "*.${ext}"
            fi

            if [[ -n "${search}" ]]; then
                ("$@" 2>/dev/null | grep --color=auto ${search}) || error_shom
            elif [[ -n "${ext}" ]]; then
                ("$@" 2>/dev/null | egrep --color=auto "\.${ext}$") || error_shom
            else
                "$@"
            fi

        # LS -> Not recursive
        else
            set -- ls -Glah
            if [[ -n "${path}" ]]; then
                set -- "$@" "${path}"
            fi

            if [[ -n "${ext}" || -n "${search}" ]]; then
                if [[ -z "${ext}" ]]; then
                    ("$@" | grep --color=auto ${search}) || error_shom
                elif [[ -z "${search}" ]]; then
                    ("$@" | egrep --color=auto "\.${ext}$") || error_shom
                else
                   ("$@" | egrep --color=auto "\.${ext}$" | grep --color=auto ${search}) || error_shom
                fi
            else
                "$@"
            fi
        fi


        echo -e "\n"

        unset ext
        unset search
        unset path
        unset recursive

    fi
    return 0
}