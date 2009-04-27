#!/bin/bash
if [[ "$FCSH_VIM_ROOT" = "" ]]; then
    FCSH_VIM_ROOT="$HOME/bin"
fi
lockdir="$FCSH_VIM_ROOT/fcsh.vim.lock"
idcurr="$lockdir/fcsh.vim.id.curr"
pipein="$lockdir/fcsh.vim.pipe.in"
pipeout="$lockdir/fcsh.vim.pipe.out"
cmpdone="$lockdir/fcsh.vim.cmp.done"
cmpnice="nice"
cmpbad="bad"
cmpre="recompile"
