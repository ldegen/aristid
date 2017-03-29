aristid = require "../src/index.coffee"

describe "deterministic, context-free", ->
  it "produces a single result", ->
    kochCurve = aristid 
      iterations: 2
      axiom: "F"
      rules: 
        F: "F+F−F−F+F"

    {expansion, p,next} = kochCurve()
    expect(expansion).to.eql "F+F−F−F+F+F+F−F−F+F−F+F−F−F+F−F+F−F−F+F+F+F−F−F+F"
    expect((p-1)*(p-1)).to.be.lessThan .0000001
    expect(next()).to.be.null

get = (p)->(o)->o[p]
sum = (a,b)->a+b

describe "stochastic, context-free", ->
  it "produces one result and an oracle to get the next", ->
    something = aristid
      iterations:2
      axiom: "F"
      rules:
        F: [
          {p:0.3, s: "-F"}
          {p:0.3, s: "+F+F"}
          {p:0.4, s: "a"}
        ]
    {p,expansion, next,all} =something()
    expect(p).to.eql 0.09
    expect(expansion).to.eql "--F"
    words = something.all()
    expect( words
      .map get 'p'
      .reduce sum
    ).to.eql 1
    expect( words.map (w)->w.p+w.expansion).to.contain w for w in [
      "0.09--F"
      "0.09-+F+F"
      "0.12-a"
      "0.027+-F+-F"
      "0.027+-F++F+F"
      "0.036+-F+a"
      "0.027++F+F+-F"
      "0.027++F+F++F+F"
      "0.036++F+F+a"
      "0.036+a+-F"
      "0.036+a++F+F"
      "0.048+a+a"
      "0.4a"
    ]

  it "runs fast enough", ->

    something = aristid
      iterations:4
      axiom: "F"
      rules:
        F: [
          {p:0.3, s: "-F"}
          {p:0.3, s: "+F+F"}
          {p:0.4, s: "a"}
        ]
    words = something.all()
    p=words
      .map get 'p'
      .reduce sum
    
    expect((p-1)*(p-1)).to.be.lessThan .0000001
