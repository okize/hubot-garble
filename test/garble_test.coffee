chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'hubot-garble', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/garble')(@robot)

  it 'does register a respond listener', ->
    expect(@robot.respond).to.have.been.calledWithMatch sinon.match( (val) ->
      val.test /hubot garble some text/
    )

  it 'does register a respond listener', ->
    expect(@robot.respond).to.have.been.calledWithMatch sinon.match( (val) ->
      val.test /hubot garble 5 some text/
    )

  it 'does NOT register a respond listener', ->
    expect(@robot.respond).to.not.have.been.calledWithMatch sinon.match( (val) ->
      val.test /hubot gargle 5 some text/
    )
