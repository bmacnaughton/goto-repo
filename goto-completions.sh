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
  # for testing without invoking the goto function.
  local simulated

  # let this run interactively for testing
  if [ "$COMP_WORDS" == "" ]; then
    local name=$1
    local simulated=true
  elif [ "${#COMP_WORDS[@]}" != "2" ]; then
    return
  else
    local name=${COMP_WORDS[1]}
  fi

  # get the parts of the name
  local IFS=$'/'
  local name_parts=($(echo "$name"))

  # how many parts of the repo path did the user supply?
  local n=${#name_parts[@]}

  # the root repository to search. need a way to set this across repos
  # and maybe languages.
  local repo_root=${GOTO_REPO_ROOT:-$HOME/github.com}
  # modify the pattern based on how specific the user was
  if [ $n -eq 1 ]; then
    local pattern="$repo_root/*/$name*"
  elif [ $n -eq 2 ]; then
    local pattern="$repo_root/${name_parts[0]}*/${name_parts[1]}*"
  elif [ $n -eq 3 ]; then
    # not sure what this is for yet.
    local pattern="$name*"
  elif [ $n -eq 0 ]; then
    # this is too many options, but it's what the user asked for
    local pattern="$repo_root/*/*"
  fi

  if [ -n "$simulated" ]; then
    echo "compgen -G with $pattern"
  fi

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

complete -F _goto_completions goto
