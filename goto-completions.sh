#!/usr/bin/bash
# source this to define the goto function and setup completion for it.

goto() {

  # script to goto a specific repo.
  # v1 - only find with github.com root of node
  local repo_root=${GOTO_ROOT:-$HOME/github.com}

  if [ -z "$1" ]; then
    echo "goto: nowhere to go"
    return 1
  fi

  if [ -d "$1" ]; then
    echo "goto: changing to $1"
    # shellcheck disable=SC2164
    cd "$1"
  elif [ -d "$repo_root/$1" ]; then
    echo "goto: changing to $1"
    # shellcheck disable=SC2164
    cd "$repo_root/$1"
  else
    echo "goto: $1 does not exist"
    return 1
  fi
}

_goto_completions()
{
  # for testing without invoking the goto function.
  local debugging

  # let this run interactively for testing
  # shellcheck disable=SC2128
  if [ -z "$COMP_WORDS" ]; then
    local name=$1
    local debugging=true
  elif [ "${#COMP_WORDS[@]}" != "2" ]; then
    return
  else
    local name=${COMP_WORDS[1]}
  fi

  # get the parts of the name
  local name_parts
  IFS='/' read -ra name_parts <<< "$name"

  # how many parts of the repo path did the user supply?
  local n=${#name_parts[@]}
  [ -n "$debugging" ] && echo "[$n name_parts]"

  # the root repository to search. need a way to set this across repos
  # and maybe languages.
  local repo_root=${GOTO_REPO_ROOT:-$HOME/github.com}

  local pattern
  local pattern2
  # modify the pattern based on how specific the user was. if there is only
  # one item make pattern2 as it might represent the user, not the user's repo.
  if [ "$n" -eq 1 ]; then
    # if the name ends in slash presume it's a user
    if [ "${name: -1}" = "/" ]; then
      local user_only=true
      pattern="$repo_root/${name%?}*"
    else
      local user_only=false
      pattern="$repo_root/*/$name*"
      pattern2="$repo_root/${name}*"
    fi
  elif [ "$n" -eq 2 ]; then
    # could be user/repo or repo/one-more-level
    pattern="$repo_root/${name_parts[0]}*/${name_parts[1]}*"
    pattern2="$repo_root/*/${name_parts[0]}*/${name_parts[1]}*"
  elif [ "$n" -eq 3 ]; then
    # handle root/user/repo/one-more-level
    pattern="$repo_root/${name_parts[0]}*/${name_parts[1]}*/${name_parts[2]}*"
  elif [ "$n" -eq 0 ]; then
    # this is too many options, but it's what the user asked for
    pattern="$repo_root/*/*"
  fi

  local sugs
  IFS=$'\n' read -ra sugs <<< "$(compgen -G "$pattern")"

  if [ -n "$debugging" ]; then
    IFS=' ' local suggestions="${sugs[*]}"
    [ -n "$debugging" ] && echo "[compgen -G with $pattern yields $suggestions]"
  fi


  COMPREPLY=()

  for s in "${sugs[@]}"; do
    if [ "$user_only" = "true" ]; then
      COMPREPLY+=("$s")
    else
      IFS="/" read -ra sug <<< "$s"
      [ -z "$debugging" ] && echo "[$s yields sug" "${sug[@]}" "]"
      local tail="${sug[-2]}/${sug[-1]}"
      # if 3 parts were specified, put the first one back in
      if [ "$n" -eq 3 ]; then
        tail="${sug[-3]}/$tail"
      fi
      COMPREPLY+=("$tail")
    fi
  done

  # if there were no suggestions, check to see if it could be a user
  if [ "${#sugs[@]}" -eq 0 ] && [ "$pattern2" != "" ]; then
    [ -n "$debugging" ] && echo "[executing compgen -G $pattern2]"
    local sugs
    IFS=$'\n' read -ra sugs <<< "$(compgen -G "$pattern2")"
    COMPREPLY+=("${sugs[@]}")
  fi

  if [ -n "$debugging" ]; then
    echo "[pretending to goto:" "${COMPREPLY[@]}" "]"
  fi

}

complete -F _goto_completions goto
