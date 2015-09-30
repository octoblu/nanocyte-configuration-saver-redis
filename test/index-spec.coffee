redis = require 'redis'
ConfigrationSaverRedis = require '../index'

describe 'ConfigrationSaverRedis', ->
  beforeEach ->
    @client =
      hset: sinon.stub()
      rename: sinon.stub()
    @sut = new ConfigrationSaverRedis @client
    @client.hset.yields null

  describe '->stop', ->
    describe 'when called with a flow', ->
      beforeEach ->
        @callback = sinon.spy()
        @sut.stop flowId: 'some-flow-uuid', @callback

      it 'should rename the flow-stop key to the flowUuid key', ->
        expect(@client.rename).to.have.been.calledWith 'some-flow-uuid-stop', 'some-flow-uuid'

      describe 'when rename yields an error', ->
        beforeEach ->
          @error = new Error 'something wong'
          @client.rename.yield @error

        it 'should yield an error', ->
          expect(@callback).to.have.been.calledWith @error

      describe 'when rename yields no error', ->
        beforeEach ->
          @client.rename.yield null

        it 'should yield an error', ->
          expect(@callback).to.have.been.calledWithNoArguments

  describe '->save', ->
    describe 'when called with flow data', ->
      beforeEach (done) ->
        @flowData =
          router:
            config: {}
            data: {}

        @sut.save flowId: 'some-flow-uuid', instanceId: 'my-instance-id', flowData: @flowData, done

      it 'should save to redis', ->
        expect(@client.hset).to.have.been.calledWith 'some-flow-uuid', 'my-instance-id/router/config', '{}'

    describe 'when called with a new set of flow data', ->
      beforeEach (done) ->
        @flowData =
          router:
            config: {}
            data: {}

        @sut.save flowId: 'other-flow-uuid', instanceId: 'my-instance-id', flowData: @flowData, done

      it 'should save the new flow data to redis', ->
        expect(@client.hset).to.have.been.calledWith 'other-flow-uuid', 'my-instance-id/router/config', '{}'

    describe 'when called with a new set of flow data', ->
      beforeEach (done) ->
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

        @sut.save flowId: 'other-flow-uuid', instanceId: 'my-instance-id', flowData: @flowData, done

      it 'should save the new flow data to redis', ->
        set = @client.hset
        expect(set).to.have.been.calledWith 'other-flow-uuid', 'my-instance-id/some-node-uuid/data', '{"cats":true}'
        expect(set).to.have.been.calledWith 'other-flow-uuid', 'my-instance-id/router/config', '{"foo":"bar"}'
        expect(set).to.have.been.calledWith 'other-flow-uuid', 'my-instance-id/router/data', '{"data":"something"}'
        expect(set).to.have.been.calledWith 'other-flow-uuid', 'my-instance-id/some-node-uuid/config', '{}'
        expect(set).to.have.been.calledWith 'other-flow-uuid', 'my-instance-id/meshblu-output/config', '{}'
        expect(set).to.have.been.calledWith 'other-flow-uuid', 'my-instance-id/meshblu-output/data', '{}'

    describe 'when data is missing', ->
      beforeEach (done) ->
        @flowData =
          foo:
            config: {}

        @sut.save flowId: 'other-flow-uuid', instanceId: 'my-instance-id', flowData: @flowData, done

      it 'should save the new flow data to redis', ->
        expect(@client.hset).to.have.been.calledWith 'other-flow-uuid', 'my-instance-id/foo/config', '{}'
        expect(@client.hset).to.have.been.calledWith 'other-flow-uuid', 'my-instance-id/foo/data', '{}'

    describe 'when config is missing', ->
      beforeEach (done) ->
        @flowData =
          foo:
            data: {}

        @sut.save flowId: 'other-flow-uuid', instanceId: 'my-instance-id', flowData: @flowData, done

      it 'should save the new flow data to redis', ->
        expect(@client.hset).to.have.been.calledWith 'other-flow-uuid', 'my-instance-id/foo/config', '{}'
        expect(@client.hset).to.have.been.calledWith 'other-flow-uuid', 'my-instance-id/foo/data', '{}'
