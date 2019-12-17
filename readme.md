# goto-repo

a bash completion script to navigate go-like source repositories.

### why?

i was playing with go and liked their source repository scheme. i now keep
my github repositories in a similar structure, e.g.,

```bash
~/
  github.com/
  bmacnaughton/
    goto-repo/
    testeachversion/
    ws/
  mochajs/
    mocha
  websockets/
    ws
```

i wanted a simple way to specify just the target and be able to navigate to
a repository, e.g., `goto goto<tab>` completes to `goto bmacnaughton/goto`
and the `goto` script changes the directory.

it only handles one root right now, i.e., `$HOME/github.com`, and it requires
line editing if there are multiple completions possible, but it does show the multiple completions on a double-tab.

```bash
$ goto ws<tab><tab>
bmacnaughton/ws  websockets/ws
$ goto ws
```

using bash editing you'd hit alt-b, insert `b/`, ctrl-e to get to the end of
the line, then hit tab again and you'll get the unique completion
`bmacnaughton/ws`.

### installing

if you've got this repo cloned into an environment like shown above then add
this line to `~/.bashrc`:

```bash
# and my own goto repo helper
[ -s "$HOME/github.com/bmacnaughton/goto-repo/goto-completions.sh" ] && \. "$HOME/github.com/bmacnaughton/goto-repo/goto-completions.sh"
```

### thoughts

i wanted to implement bash completion and chose this. there are a few things
i'd like to fix but it works well enough until i have time to fiddle with it
some more.

- consider putting the logic into the `goto` function
- if only one arg, and it's not found, try it as username, not repo name.

### bcompare-completions

i use bcompare and just added a simple completer for it. it's got nothing to
do with repo completion but didn't seem to be worth creating a new repo for.
