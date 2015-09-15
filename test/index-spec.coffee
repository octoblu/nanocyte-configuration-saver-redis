redis = require 'redis'
ConfigrationSaverRedis = require '../index'

describe 'ConfigrationSaverRedis', ->
  it 'should exist', ->

    @sut = new ConfigrationSaverRedis

  describe '->save', ->
    describe 'when called with flow data', ->
      beforeEach ->
        @client = redis.createClient()
        sinon.stub @client, 'set'
        @flowData =
          router:
            config: {}
            data: {}

        @sut = new ConfigrationSaverRedis flowId: 'some-flow-uuid', flowData: @flowData, {client: @client}
        @sut.save()

      it 'should save to redis', ->
        expect(@client.set).to.have.been.calledWith 'some-flow-uuid/router/config', '{}'

    describe 'when called with a new set of flow data', ->
      beforeEach ->
        @client = redis.createClient()
        sinon.stub @client, 'set'
        @flowData =
          router:
            config: {}
            data: {}

        @sut = new ConfigrationSaverRedis flowId: 'some-other-flow-uuid', flowData: @flowData, {client: @client}
        @sut.save()

      it 'should save the new flow data to redis', ->
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/router/config', '{}'

    describe 'when called with a new set of flow data', ->
      beforeEach ->
        @client = redis.createClient()
        sinon.stub @client, 'set'
        @flowData =
          router:
            config:
              foo: 'bar'
            data:
              data: "something"
          'some-node-uuid':
            config: {}
            data:
              cats: true
          'meshblu-output':
            config: {}
            data: {}

        @sut = new ConfigrationSaverRedis flowId: 'some-other-flow-uuid', flowData: @flowData, {client: @client}
        @sut.save()

      it 'should save the new flow data to redis', ->
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/some-node-uuid/data', '{"cats":true}'
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/router/config', '{"foo":"bar"}'
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/router/data', '{"data":"something"}'
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/some-node-uuid/config', '{}'
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/meshblu-output/config', '{}'
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/meshblu-output/data', '{}'

    describe 'when data is missing', ->
      beforeEach ->
        @client = redis.createClient()
        sinon.stub @client, 'set'
        @flowData =
          foo:
            config: {}

        @sut = new ConfigrationSaverRedis flowId: 'some-other-flow-uuid', flowData: @flowData, {client: @client}
        @sut.save()

      it 'should save the new flow data to redis', ->
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/foo/config', '{}'
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/foo/data', '{}'

    describe 'when config is missing', ->
      beforeEach ->
        @client = redis.createClient()
        sinon.stub @client, 'set'
        @flowData =
          foo:
            data: {}

        @sut = new ConfigrationSaverRedis flowId: 'some-other-flow-uuid', flowData: @flowData, {client: @client}
        @sut.save()

      it 'should save the new flow data to redis', ->
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/foo/config', '{}'
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/foo/data', '{}'
