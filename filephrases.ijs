NB.from http://www.jsoftware.com/jwiki/Phrases/Files
NB. definitions used in this script:
butifnull =: 2 : 'v"_`u@.(*@#@])'
bivalent =: 2 : 'u^:(1:`(]v))'
keyskl =: 0&({"1"_) :({"1"_)
cullkl =: 2 : '(u bivalent(n&{"1)#])ifany'
ifany =: ^:(*@#@])
ifanyx =: ^:(*@#@[)
endtoend =: 1 : ';@:(<@u)'
usedtocull =: 1 : 'u#]'
null =: (0 2$0)"_

NB. =========================================================
NB. Listing Files

NB. y is (possibly boxed) filename search path
NB. Sample y is 'C:\j\system\*.ijs'
NB. Result is list of files in the path - qualified to the same level
NB. as given in y (i. e. relative to the same directory that y starts in)
searchdir =: 13 : '(({.~ >:@(''\:''&(i:&1@(e.~))))L:0 y) ,&.> butifnull (0$a:) 0 {"1 (1!:0) y'

NB. Adverb.  [x] u is applied on the list of files in the (boxed) search path y
NB. Sample y is 'C:/j/system/*.ijs'.  The filename supplied to u is
NB. boxed and qualified at the same level as y  The argument to u may be null
ondir =: 1 : 'u bivalent searchdir'

NB. y is boxed name of directory (no file specifier within the directory)
NB. Result is list of subdirectories, full name
subdir =: ( (, '\'&,)&.>   (keyskl @ (('d'&=@(4&{)@>) cullkl 4) butifnull (0$a:)) @ (1!:0) @ (,&'\*.*'&.>) )"0

NB. y is boxed search path, e. g. <'C:/j/system/*.ijs'
NB. result has one level of subdirectory added, with the file specifier
NB.  unchanged, e. g. 'C:/j/system/winapi/*.ijs';...
subdirpath =: ( (subdir@({.&.>) ,&.> }.&.>)~ i:&'\'&.> )"0

NB. Adverb. y is boxed filename search path (filename\extension).  Apply [x] u to each
NB. (boxed) filename matching the extension, first in subdirectories (recursively) and then
NB. in the named directory  Result is the results from u, with the
NB. results from this directory first, then subdirectories
NB. The part at the end creates a list of subdirectories with paths
NB. attached, i. e. 'c:/j/*.ijs' -> 'c:/j/system/*.ijs';'c:/j/user/*.ijs'
NB. Example: ] recursivelyonfiles <'C:\j\system\*.ijs'
NB. to create the list of all scripts under c:\j\system
NB. NOTE: this adverb uses recursion, so it must be sequestered in a verb
NB.  of its own rather than being part of a train, i. e.
NB.  ] recursivelyonfiles @ (<@,&'\*.*')
NB.  is no good because the <@... is part of the recursion
recursivelyonfiles =: 1 : '( u ondir  ,~ifanyx~  $:"0 _ 0 endtoend ifany bivalent subdirpath )"0 _ 0'

NB. =========================================================
NB. Operations on Files

NB. y is boxed filename search path (filename\extension)
NB. Files matching the extension are deleted in the subdirectories of the path, and
NB. then in the path itself (and recursively in those subdirectories)
recursivedeletefiles =: null@:((1!:55 :: null)"0) recursivelyonfiles @ boxopen

NB. x is character string, y is boxed filename search path
NB. Result is script file names containing x
findinscript =: 4 : 0
x ((isinstring  1!:1) " _ 0 usedtocull) searchdir y
)

NB. x is character string, y is filename search path
NB. files with the strings are opened
editinscript =: 4 : 0
(null @: wd @: ('smsel "'&,) @: (,&'";smopen') @: >) " 0 x findinscript y
)

NB. =========================================================
NB. Utilities for User-Specified Operations on Files

NB. Adverb.  [x] u is applied to file(s) y
onfile =: 1 : '(u bivalent (1!:1))"0 _ 0 ifany'
NB. Adverb.  [x] u is applied to file(s) y, and the file is rewritten
modfile =: 1 : '((u bivalent (1!:1)) 1!:2 ])"0 _ 0 ifany'
NB. Adverb.  Applies [x] u to the data in files described by path y, without writing the file
applytofiles =: onfile ondir
NB. Adverb.  Applies x u to the data in files described by path y, write results to the file
modifyfiles =: modfile ondir

NB. Count words in file.  Returns #lines with string, # blank lines, #comment lines.  y is file data
NB. x, if given, is string to search for in lines, returning count containing it.  Default
NB. is '', which appears in all lines & gives a count of # lines
wcfile =: (''&$:) : (13 : '+/ x ( isinstring , (0&=)@#@] , (''NB.''&-:)@(3&{.)@] )S:_ 0 (}.~ <:@(i.&0)@('' ''&=)) L:0 <;._1@:(LF&,) y')

NB. y is file descriptor, result is total wcfile in all files.  x, if given, is string to
NB. check for
wcfiles =: +/ @: (wcfile applytofiles)

NB. x is string, y is file data
NB. lines starting with x (after removing leading blanks) are deleted
NB. We add an LF and take it away when we're done
dellinesprefixed =: 13 : '}: ; x ( (,&LF@])`(''''"_) @. ( ([ -: (#@[ {. ]))  (}.~ (i.&0)@('' ''&=)) ) ) L:0 <;._1@:(LF&,) y'
