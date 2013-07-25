# cd_cache.sh

##
## Create a new cachable `cd'
##

_GOTO_CACHE_SIZE=32

declare -a DIRS

cd()
{
    local i d
    local dst=$1
    local RETVAL

    if [ $# -eq 0 ]; then
        builtin cd
        return $?
    fi

    if [ ! -d $dst ]; then
        for ((i=0; $i<${#DIRS[@]}; i=$i+1)); do
            if [ "$dst" = "$i" ]; then
                builtin cd "${DIRS[$i]}"
                return $?
            fi
        done
    fi

    builtin cd "$dst"
    RETVAL=$?
    if [ $RETVAL -ne 0 ]; then
        return $RETVAL
    fi

    # Ignore existing entry
    for d in ${DIRS[@]}; do
        if [ "$d" = "$PWD" ]; then
            return 0
        fi
    done

    # Push entry in "FIFO" mode
    if [ ${#DIRS[@]} -lt $_GOTO_CACHE_SIZE ]; then
        DIRS[${#DIRS[@]}]=$PWD
    else
        for ((i=0; $i<$_GOTO_CACHE_SIZE; i=$i+1)); do
            DIRS[$i]=${DIRS[$i+1]}
        done
        DIRS[$_GOTO_CACHE_SIZE-1]=$PWD
    fi

    # Export env. variable d0, d1, d2, ...
    for ((i=0; $i<${#DIRS[@]}; i=$i+1)); do
        export d$i=${DIRS[$i]}
    done

    return $RETVAL
}

lsd()
{
    local i=0 d
    for d in ${DIRS[@]}; do
        echo "$i \$d$i $d"
        ((i=$i+1))
    done
}

