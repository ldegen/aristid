aristid = require "../src/index.coffee"

describe "deterministic, context-free", ->
  it "produces a single result", ->
    kochCurve = aristid 
      iterations: 2
      axiom: "F"
      rules: 
        F: "F+F−F−F+F"

    {s, p} = kochCurve()
    expect(s).to.eql "F+F−F−F+F+F+F−F−F+F−F+F−F−F+F−F+F−F−F+F+F+F−F−F+F"
    expect((p-1)*(p-1)).to.be.lessThan .0000001

get = (p)->(o)->o[p]
sum = (a,b)->a+b

oracle = (nums...)->
  i=0
  (rules)->
    if rules? and rules.length>0
      choice = nums[i % nums.length]
      #console.log "oracle: i=%d, choice=%d", i, choice
      i=i+1
      rules[choice]

describe "stochastic, context-free", ->
  it "produces one result using an oracle for all decisions", ->
    something = aristid
      iterations:2
      axiom: "F"
      rules:
        F: [
          {p:0.3, s: "-F"}
          {p:0.3, s: "+F+F"}
          {p:0.4, s: "a"}
        ]
    {p,s} =something oracle 1, 0, 2

    # p:1           s:F
    # p:0.3         s:+F+F 
    # p:0.3*0.3*0.4 s:+-F+a

    expect(p).to.eql 0.036
    expect(s).to.eql "+-F+a"
