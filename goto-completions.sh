# source this to define the goto function and setup completion for it.

goto() {

  # script to goto a specific repo.
  # v1 - only find with github.com root of node
  local repo_root=${GOTO_REPO_ROOT:-$HOME/github.com}

  if [ -z "$1" ]; then
    echo "goto: nowhere to go"
    return 1
  fi

  if [ -d "$1" ]; then
    echo "goto: changing to $1"
    cd "$1"
  elif [ -d "$repo_root/$1" ]; then
    echo "goto: changing to $1"
    cd "$repo_root/$1"
  else
    echo "goto: $1 does not exist"
    return 1
  fi
}

_goto_completions()
{
  # for testing without invoking the function.
  local simulated
  # the root repository to search. need a way to set this across repos, languages,
  # maybe.
  local repo_root=${GOTO_REPO_ROOT:-$HOME/github.com}

  # let this run interactively for testing
  if [ "$COMP_WORDS" == "" ]; then
    local name=$1
    local simulated=true
  elif [ "${#COMP_WORDS[@]}" != "2" ]; then
    return
  else
    local name=${COMP_WORDS[1]}
  fi

  # how many slashes are in the name? (n)
  #local len=${#name}; local count=${name//\//}; local count=${#count}; local n=$((len-count));

  local pattern="$repo_root"

  # get the parts of the name
  local IFS=$'/'
  local name_parts=($(echo "$name"))

  local n=${#name_parts[@]}

  if [ $n -eq 1 ]; then
    local pattern="$pattern/*/$name*"
  elif [ $n -eq 2 ]; then
    local pattern="$pattern/${name_parts[0]}*/${name_parts[1]}*"
  elif [ $n -eq 3 ]; then
    local pattern="$name*"
  fi

  #echo "pattern: $pattern"

  local IFS=$'\n'
  local sugs=($(compgen -G "$pattern"))

  COMPREPLY=()

  for s in "${sugs[@]}"
  do
    local IFS=$'/'
    local sug=($(echo "$s"))
    local IFS=$''
    local tail="${sug[-2]}/${sug[-1]}"
    COMPREPLY+=($tail)
  done

  if [ -n "$simulated" ]; then
    echo "pretending to goto: ${COMPREPLY[@]}"
  fi

}

complete -F _goto_completions -D goto
