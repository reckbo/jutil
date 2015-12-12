NB.http://code.jsoftware.com/wiki/User:Joe_Bogner/ByteCodeInterpreter#Tacit_Literate.2C_TDD_Version
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

STRS=:'exiting';'greater than'
(OPS) =: i.#OPS=:;:'POP PUSH ADD CMP EXIT LABEL JGE DSTR'
dispatchTable =: ('op_' , tolower) each OPS

NB. a boxed struct is supplied as Y to operands
NB. positions of values in struct,
NB. 0 = get/setCODE = code (required for jumps)
NB. 1 = get/setIP = Instruction Pointer
NB. 2 = get/setVAL = present value (e.g. popped value)
NB. 3 = get/setSTACK = stack

makeStruct=: 3 : 0
    for_c. y do.
      ('get',(>c)) =: c_index {:: ]
      ('set',(>c)) =: <@:[ (c_index) } ]
    end.
    (#y) $ (<'')
    NB. (i.@#  4 : '(y) =: x {:: ] label_. y' each ]  )  ;:
)

testStruct =: makeStruct 'CODE';'IP';'VAL';'STACK'

log=:smoutput bind ([;])

func 'op_push'
    pushes a value on the stack
    ex: (getSTACK 1 op_push testStruct) -: (,1)
    ex: (getSTACK 2 op_push 1 op_push testStruct) -: (2,1)
    op_push =: ((0{[) ,  getSTACK) setSTACK ]
)

func 'op_pop'
    pops a value from the stack and puts it in the val position
    ex: ((getVAL;getSTACK) op_pop 2 op_push 1 op_push testStruct ) -: (2;(,1))
    op_pop =: {. @: getSTACK setVAL ] @: }. @: getSTACK setSTACK ]
)

func 'op_add'
    adds two numbers and pushes to stack.
    input is (opcode, x, y)
    ex: (getSTACK (_,1,3) op_add testStruct) -: (,4)
    op_add=: (+/ @: }. @: [) op_push ]
)

func 'popn'
    pops n values from the stack and appends the values in the value slot
    ex: (getVAL 2 popn 1 op_push 2 op_push testStruct) -: (2,1)
    popn=: 1 : '[: ( ((getVAL @: ] , getVAL @: [) setVAL ]) op_pop)^:m ]'
)

func 'op_cmp'
    pops two values from the stack and and returns _1 0 1 for whether the last value is
    less than, equal, greater than the previous value
    ex: (getSTACK op_cmp 1 op_push 2 op_push testStruct) -: (,_1)
    ex: (getSTACK op_cmp 2 op_push 2 op_push testStruct) -: (,0)
    ex: (getSTACK op_cmp 3 op_push 2 op_push testStruct) -: (,1)
    op_cmp=: (((*@-~)/ @: getVAL op_push ]) 2 popn)
)

func 'op_exit'
    sets execution to exit by placing a large number as the next instruction
    ex: (getIP op_exit testStruct) -: 9e999
    op_exit =:   (9e999)&setIP
)

func 'op_label'
    marks a instruction as a label
    op_label =: ]
)

func 'findLabel'
    returns the index of the label in the code
    x: param1 is label to find where x is (op, param1, param2)
    y: byteCodeStruct
    ex: 1 -: ((_,100,0) findLabel ((0,0,0),(LABEL,100,0),:(EXIT,0,0)) setCODE testStruct) NB. found on 1
    ex: 3 -: ((_,999,0) findLabel ((0,0,0),(LABEL,100,0),:(EXIT,0,0)) setCODE testStruct) NB. not found
    ex: 3 -: ((_,100,0) findLabel ((0,0,0),(LABEL,999,0),:(EXIT,0,0)) setCODE testStruct) NB. not found
    ex: 0 -: ((_,100,0) findLabel ((LABEL,100,0),(LABEL,999,0),:(EXIT,0,0)) setCODE testStruct) NB. found on 0
    findLabel=: ((2&{."1) @: getCODE) i. (LABEL,(1{::[))
)

func 'op_jge'
    pops value from stack.
       if value is >= 0, sets instruction pointer to the label.
       otherwise continues

    x: bytecode where (op,param1,param2) and param2 indicates label to jump to
    y: bytecodeStruct

    (_,_,_) is a placeholder since the true x value is supplied and not looked up


    no change test (ip remains 0 since _1 is top of stack):   
    ex: 0 -: getIP (JGE,100,0) op_jge _1 op_push ((_,_,_),(LABEL,100,0),:(EXIT,0,0)) setCODE 0 setIP testStruct

    greater than jump (ip goes to 1 since 1 is top of stack and 1 is the label position):  
    ex: 1 -: getIP (JGE,100,0) op_jge 1 op_push ((_,_,_),(LABEL,100,0),:(EXIT,0,0)) setCODE 0 setIP testStruct

    another jump (move label to the end)
    ex: 2 -: getIP (JGE,100,0) op_jge 1 op_push ((_,_,_),(EXIT,0,0),:(LABEL,100,0)) setCODE 0 setIP testStruct

    jump but label is not found
    ex: 3 -: getIP (JGE,999,0) op_jge 1 op_push ((_,_,_),(EXIT,0,0),:(LABEL,100,0)) setCODE 0 setIP testStruct

    test equals (this is not yet implemented)
    ex: 2 -: getIP (JGE,100,0) op_jge 0 op_push ((_,_,_),(EXIT,0,0),:(LABEL,100,0)) setCODE 0 setIP testStruct

    op_jge =:  (findLabel setIP ])^:(0<:getVAL) op_pop
)

func 'op_str'
    outputs a string from the global STRS table
    ex: (DSTR,0,1) op_dstr testStruct [ outStr=: [
    op_dstr =: (outStr @: (1&{:: @: [) ] ])
)

func 'outStr'
    outputs a string from the global STRS table
    TODO: implement a way to deal with strings more elegantly (no globals)
    no example due to side effects
    outStr =:  smoutput {&STRS
)


func 'incIP'
    increments instruction counter in struct
    ex: 1-: (getIP incIP 0 setIP testStruct)
    incIP=: (>: @: getIP) setIP ]
)

func 'dispatch'
    executes the byte code pointed by the instruction pointer
    x: bytecode struct
    ex: 9: -: getVAL op_pop dispatch ((ADD,5,4),:(0,0,0)) setCODE 0 setIP testStruct
    ex: 5: -: getVAL op_pop dispatch ((ADD,5,4),:(ADD,2,3)) setCODE 1 setIP testStruct
    dispatch=: (getIP { getCODE) dispatchTable @. (0{:: [) ]
)

func 'eval'
    dispatches and increments the instruction pointer
    ex: 1: -: getIP dispatch ((ADD,5,4),:(0,0,0)) setCODE 0 setIP testStruct
    eval=:  incIP @: dispatch
)

func 'evall'
    evals with a log per iteration
    evall=:((smoutput bind [) ] ])  @: eval
)

func 'tooFar'
    returns 0 if the instruction pointer is past the length of the code
    ex: 1 -: tooFar 0 setIP (3 3 $ 0) setCODE testStruct
    ex: 0 -: tooFar 1000 setIP (3 3 $ 0) setCODE testStruct
    tooFar=: 1 = (getIP < (<: @: # @: [))
)

func 'run'
   evaluates bytecode
   ex: 4 -: getVAL op_pop run (ADD,1,3),:(EXIT,0,0)
   run=: ((eval^:( tooFar )^:_)(];&(0;'';''))) f.
)   

func 'runlog'
    evaluates bytecode in log mode
    runlog=: (evall^:( tooFar )^:_)(];&(0;'';'')) f.
)    

func 'parse'
     parses a string of bytecode and returns a Nx3 array of values
     ex-: (2 3 $ 2 1 2 4 0 0) -: parse ('ADD 1 2',LF,'EXIT',LF)
     parse =: ([: 3&{."1  ((".;._2 @ (,&' ')) ;._2))
)     

NB. run (ADD,4,2),:(EXIT,0,0)
NB. run parse ('ADD 4 2',LF,'EXIT 0 0',LF)

NB. timing
NB. prog=: parse ,  > 500000 # (<'ADD 1 5',LF,'POP',LF)

smoutput run (ADD,4,2),:(EXIT,0,0)


NB. shows the 2nd string (1) since JGE matches
prog2 =: 0 : 0
ADD 1 0
ADD 2 0
CMP
JGE 100
DSTR 0
EXIT
LABEL 100
DSTR 1
EXIT
)

smoutput run parse prog2
