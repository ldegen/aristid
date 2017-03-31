Promise = require "bluebird"
WeightedRandom = require "./weighted-random"
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
    r=rules[symbol] ? []


  expand = (oracle) -> ({p:p0,s:input}, iteration) ->
    expansion = ""
    p=1
    for position in [0...input.length]
      symbol = input[position]
      candidateRules = matchingRules symbol, position, input
      rule = oracle candidateRules
      if rule?
        #console.log "at", position, "use", rule
        expansion += rule.s
        p *= rule.p
      else
        expansion += symbol
    #console.log "expansion",iteration,input," --> ", expansion
    p: p0 * p
    s: expansion

  rnd = (rules)->
    wr = WeightedRandom rules.map ({p})->p
    rules[wr()]

  (oracle = rnd)->
    [0...iterations].reduce expand(oracle), p:1, s:axiom

module.exports = aristid
