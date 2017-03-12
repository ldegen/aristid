Promise = require "bluebird"
{Seq,Stack, fromJS,Record,Range} = require "immutable"
{isArray} = require "util"
aristid = ({axiom:axiom, rules:rules0, iterations=1}={})->

  rules = {}

  normalizeRules = (rs0)->
    sum = (a,b)->a+b
    p = ({p=1})->p
    rs = rs0.map (r)->if typeof r is "string" then {p:1,s:r} else r
    psum = rs
      .map p
      .reduce sum, 0
    rs
      .map ({p,s})->{p:p/psum, s}


  for key,value of rules0
    rules[key] = normalizeRules if isArray value then value else [value]


  matchingRules = (symbol,position,word)->
    r=rules[symbol]


  Cx = Record
    input:axiom
    expansion:""
    p:1
    position:0
    iteration:0
    selection:0

  firstChoice = new Cx
  emptyStack = Stack()
  initialStack = emptyStack.push firstChoice
  start = ()->
    findSolution initialStack

  continuation = (stack=emptyStack)->()->findSolution stack


  # starts or continues expanding a word, producing
  # a stack of context frames. 
  # The top frame contains the result of the expansion
  # The remaining frames are new choice points created during 
  # the expansion that can be continued at using this function
  expand = (cx, choices=emptyStack)->
    {input,expansion,p,selection, position:position0} = cx
    #console.log "input", input
    for position in [position0...input.length]
      symbol = input[position]
      rs =  matchingRules symbol, position, input
      rule = rs?[selection]
      if rule
        #console.log symbol, position, selection,rule.s
        selection = selection + 1
        if selection < rs.length
          choices = choices.push( cx
            .set "position", position
            .set "selection", selection
            .set "p", p
            .set "expansion", expansion
          )
        selection=0
        expansion += rule.s
        p *= rule.p
      else
        expansion += symbol
    #console.log "expansion", expansion
    result = cx
      .set "position", position
      .set "selection", selection
      .set "p", p
      .set "expansion", expansion
    choices.push result


  reducer = (stack,i)->
    cx0 = stack.peek()
    cx = if cx0.selection then cx0 else 
      cx0
        .set "iteration",i
        .set "expansion", ""
        .set "input", if i>0 then cx0.expansion else axiom
        .set "position", 0
    expand cx, stack.pop()

  findSolution = (stack)->
    return null if stack.isEmpty()
    {iteration} =stack.peek()
    choices = Range(iteration,iterations).reduce reducer, stack
    {p,expansion}=choices.peek()
    next = continuation choices.pop()
    p:p
    expansion:expansion
    next: next
      
  allSolutions = (stack)->
    solutions = []
    sl = findSolution stack
    while sl?
      solutions.push sl
      sl=sl.next()
    solutions
    


  api = ()-> findSolution initialStack
  api.all = ()-> allSolutions initialStack
  api
module.exports = aristid
