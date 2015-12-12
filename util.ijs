pad0s=: 4 : 'y (<x+&.>i.&.>$y)}0$~(2*x)+$y'
expand0s=: 4 : 'y (<i.each $y)} 0 $~ x'
ii=: ] {. [: i. 10 #~ #   NB. utility verb: make self-indexing array

ts=: 6!:2 , 7!:2@]    NB. time and space e.g. ts 'f y'

'`NOT OR AND LSHIFT RSHIFT' =: (65535&-)`(23 b.)`(17 b.)`(65535 (17 b.) (33 b.)~)`(33 b.~ -)

NB. creates and documents a function
NB. could be improved to split out example
NB. or automatically assert on the example
NB. originally from http://www.jsoftware.com/pipermail/programming/2014-July/038316.html
func=: 3 : 0
doc=.[(y,'_doc')=: 0 : 0
lines=.dlb each LF cut doc
0!:0 > {: lines
examples=.[(y,'_examples')=:3 }. each (#~ (<'ex:') E. 3 {. each [) lines
for_ex. examples do.
    ex=.(>ex)
    try. 
        assert ". ex
    catch.
        smoutput ex , ' failed'
        smoutput 'returned '
        smoutput ". ex
    end.

end.
''
)
NB. e.g.
NB.func 'op_push'
    NB.pushes a value on the stack
    NB.ex: (getSTACK 1 op_push testStruct) -: (,1)
    NB.ex: (getSTACK 2 op_push 1 op_push testStruct) -: (2,1)
    NB.op_push =: ((0{[) ,  getSTACK) setSTACK ]
NB.)

NB.>  What a clever approach to cleaning up the code:
NB.>  using an adverb definition for a noun. Great!
NB.http://www.jsoftware.com/pipermail/programming/2007-November/008878.html
NB.sam=: ''1 :(0 :0-.LF)
  NB.(({. + {: * i.@(>.@((1&{ - {.) % {:))) ,
   NB.1&{)@(3&{.@(({.~ (# + _3&*@(1: = #))) ,
    NB.%&100@(-~/@(_2&{.))))

  NB.:({.@[ ({.@] + ((1&{@] - {.@]) % [) *
   NB.i.@(1: + [)) (>@(2&>@#) |. 2&{.)@])
NB.)
NB.Xn =: 1 : 'u 1 : (; <@:('' '' ,~ }:^:(''NB.'' -: 3 {.&> {:)&.;:);._2 (0 :0))'
