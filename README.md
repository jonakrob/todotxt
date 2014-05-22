Todo.txt listsmart add-on
=========================
Add-on for todo.txt-cli (https://github.com/ginatrapani/todo.txt-cli). Lists todo tasks based on project and context keywords with smart correction based on Levenshtein distance of words.

Installation
============
Install the listsmart add-on to your default add-on directory ~/.todo.txt.d.

Usage
=====
./todo.sh listsmart KEYWORD

Example:
./todo.sh listsmart +Scool # lists all tasks with school projects (Scool -> School misspell)
