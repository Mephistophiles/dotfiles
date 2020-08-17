" Vim syntax file
" Language:	redminer commit file
" Maintainer:	Tim Pope <vimNOSPAM@tpope.org>
" Filenames:	*.git/COMMIT_EDITMSG
" Last Change:	2016 Aug 29

if exists("b:current_syntax")
  finish
endif

syn case match

if has("spell")
  syn spell toplevel
endif

syn region  redminerNotePlace start=/%^[^#]/ end=/^#/
syn match   redminercommitNote           "\%^\_.\{1,255}" nextgroup=redminercommitNoteOverflow containedin=redminerNotePlace contains=TOP
syn match   redminercommitNoteOverflow   ".*" contained containedin=redminerNotePlace contains=TOP
syn match   redminercommitComment        "^#.*"
syn region  redminercommitSubject        start=/# ---------- >8 ----------/rs=e+1,hs=e+1 end=/# vim: tw=80 fo+=t/re=s-1,he=s-1 containedin=redminercommitComment
syn match   redminercommitTimerID        "@\d\+"                                                                               containedin=redminercommitSubject
syn match   redminercommitTicketID       " \zs#\d\+"                                                                           containedin=redminercommitSubject
syn match   redminercommitWastedHours    "\d\+ hours\?"                                                                        containedin=redminercommitSubject
syn match   redminercommitWastedMinutes  "\d\+ minutes\?"                                                                      containedin=redminercommitSubject
syn match   redminercommitWastedSeconds  "\d\+ seconds\?"                                                                      containedin=redminercommitSubject
syn match   redminercommitTimestamp      "\S\+ at \d\{2}:\d\{2}:\d\{2}"                                                        containedin=redminercommitSubject
" syn match   redminercommitHashes         "# "                                                                                  containedin=redminercommitSubject

hi def link redminercommitNote          Keyword
hi def link redminercommitNoteOverflow  Error
hi def link redminercommitComment       Comment
hi def link redminercommitSubject       String
hi def link redminercommitTimerID       Type
hi def link redminercommitTicketID      Type
hi def link redminercommitWastedHours   Underlined
hi def link redminercommitWastedMinutes Underlined
hi def link redminercommitWastedSeconds Underlined
hi def link redminercommitTimestamp     Underlined
hi def link redminercommitHashes        Ignore

let b:current_syntax = "redminercommit"
