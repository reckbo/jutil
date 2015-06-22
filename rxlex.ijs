NB. rxlex - regex lexer
NB.
NB. 10/26/06 Oleg Kobchenko
NB. 09/09/07 Oleg Kobchenko - word formation LEX4
NB. see http://www.jsoftware.com/jwiki/Essays/Regex_Lexer

require 'regex'

lxdefine=: 1 : '''(?x)'' , m : 0'
lxresult=: ((1 i.~[:*@,(1 1,:_ 1)&(];.0)) , {.)"2
lxmatches=: lxresult@rxmatches
lxfrom=: >@(([:' ['&,,&']')&.>)@rxfrom
lxview=: lxmatches (":@[ ,. }."1@[ lxfrom ]) ]

NB. =========================================================
LEX1=: '(\s+)|([a-z]+)|(.+)'            NB. space | word | error

TEST1a=: 'one two   three'              NB. normal test
TEST1b=: 'one two1 three'               NB. error
TEST1c=: ($~ 1000*#)'one two   three '  NB. 16000 chars

NB. =========================================================
LEX2=: noun lxdefine
  ( \s+    )|# 0 space
  ( [a-z]+ )|# 1 words
  ( .+     ) # 2 error
)

NB. =========================================================
LEX3=: noun lxdefine
  ( <[a-z][^>]*>                   )|# 0 beg tag
  ( </[a-z][^>]*>                  )|# 1 end tag
  ( <\?(?:[^?]|\?[^>])*\?>         )|# 2 pi
  ( <!--(?:[^-]|-[^-]|--[^-]|)*--> )|# 3 comment
  ( [^<>]+                         )|# 4 text
  ( .+                             ) # 5 error
)

NB. =========================================================
LEX4=: noun lxdefine
  ( [0-9_][0-9a-z_\t .]*[.:]*      )|# 0 numeric
  ( NB\..*                         )|# 1 comment
  ( [a-z][0-9a-z_]*[.:]*           )|# 2 alpha
  ( '(''|[^'])*'                   )|# 3 string
  ( \r?\n|\r                       )|# 4 line break
  ( [ \t]+                         )|# 5 space
  ( .[.:]*                         )|# 6 symbol
  ( .+                             ) # 7 error
)

TEST3a=: '<a>qq</b>'
TEST3b=: ' <? zz ?><a>qq</b>'
TEST3c=: '<a> <!-- cc --> </b>'
TEST3d=: ' <? zz ?><a>qq</b><error'
TEST3e=: ' <? zz ?><a>qq</b>< error>'
TEST3f=: ($~ 1000*#)' <? zz ?><a>qq</b>'

TEST4a=: '11+2'
TEST4b=: '11.2-2 3 4'
TEST4c=: '11.2 - 2 3 4'
TEST4d=: 'ab_c - 2 3 4'
TEST4e=: 'ab_12_ - 2 3 4'
TEST4f=: 'ab_c -/ 2 3 4'
TEST4g=: 'ab_c: -./ i.2 3 4'
TEST4h=: 'ab_c: -./ i.2 3 NB. 3 4'
TEST4i=: 'ab ; ''cd''''ef'' ,": 2 3 4'
TEST4j=: '1 2+3 2',LF,'4 2',CR,'5 2',CRLF,'6 2'


NB. =========================================================
ts=: 6!:2 , 7!:2@]

0 : 0
LEX1 lxview TEST1a
LEX1 lxview TEST1b
ts 'LEX1 lxmatches TEST1c'

(LEX1 lxmatches TEST1a) -: LEX2 lxmatches TEST1a
(LEX1 lxmatches TEST1b) -: LEX2 lxmatches TEST1b
ts 'LEX2 lxmatches TEST1c'

LEX3 lxview TEST3a
LEX3 lxview TEST3b
LEX3 lxview TEST3c
LEX3 lxview TEST3d
LEX3 lxview TEST3e
ts 'LEX3 lxmatches TEST3f'

LEX4 lxview TEST4a
LEX4 lxview TEST4b
LEX4 lxview TEST4c
LEX4 lxview TEST4d
LEX4 lxview TEST4e
LEX4 lxview TEST4f
LEX4 lxview TEST4g
LEX4 lxview TEST4h
LEX4 lxview TEST4i
LEX4 lxview TEST4j

LEX4 lxmatches TEST4i

z=: 1e4 $ 'abcolumb+boustrophedonic-chthonic*'
10{.LEX4 lxview z

ts 'LEX4 lxmatches z'
ts ';: z'
)
