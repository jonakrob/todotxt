Todo.txt listsmart add-on
=========================
Add-on for `todo.txt-cli` (https://github.com/ginatrapani/todo.txt-cli). Lists todo tasks based on project and context keywords with smart correction based on Levenshtein distance of words.

## Installation
Install the `listsmart.sh` add-on to your default add-on directory `~/.todo.txt.d` as you would do with other add-ons.

## Usage
```bash
./todo.sh listsmart KEYWORD
```

Example:
```bash
./todo.sh listsmart @Scool      # lists all tasks with school context ("School" misspell)
./todo.sh listsmart +Acounting  # lists all tasks with accounting project ("Accounting" misspell)
```

## Notes
The Levenshtein distance used for keyword correction can be configured by setting `TODOTXT_DIST` variable. The default value is 1 (at most 1 edit difference).
