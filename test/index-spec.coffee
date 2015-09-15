redis = require 'redis'
ConfigrationSaverRedis = require '../index'

describe 'ConfigrationSaverRedis', ->
  describe '->save', ->
    describe 'when called with flow data', ->
      beforeEach ->
        @client = redis.createClient()
        sinon.stub @client, 'set'
        @flowData =
          router:
            config: {}
            data: {}

        @sut = new ConfigrationSaverRedis flowId: 'some-flow-uuid', instanceId: 'my-instance-id', flowData: @flowData, {client: @client}
        @sut.save()

      it 'should save to redis', ->
        expect(@client.set).to.have.been.calledWith 'some-flow-uuid/my-instance-id/router/config', '{}'

    describe 'when called with a new set of flow data', ->
      beforeEach ->
        @client = redis.createClient()
        sinon.stub @client, 'set'
        @flowData =
          router:
            config: {}
            data: {}

        @sut = new ConfigrationSaverRedis flowId: 'some-other-flow-uuid', instanceId: 'my-instance-id', flowData: @flowData, {client: @client}
        @sut.save()

      it 'should save the new flow data to redis', ->
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/my-instance-id/router/config', '{}'

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

        @sut = new ConfigrationSaverRedis flowId: 'some-other-flow-uuid', instanceId: 'my-instance-id', flowData: @flowData, {client: @client}
        @sut.save()

      it 'should save the new flow data to redis', ->
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/my-instance-id/some-node-uuid/data', '{"cats":true}'
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/my-instance-id/router/config', '{"foo":"bar"}'
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/my-instance-id/router/data', '{"data":"something"}'
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/my-instance-id/some-node-uuid/config', '{}'
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/my-instance-id/meshblu-output/config', '{}'
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/my-instance-id/meshblu-output/data', '{}'

    describe 'when data is missing', ->
      beforeEach ->
        @client = redis.createClient()
        sinon.stub @client, 'set'
        @flowData =
          foo:
            config: {}

        @sut = new ConfigrationSaverRedis flowId: 'some-other-flow-uuid', instanceId: 'my-instance-id', flowData: @flowData, {client: @client}
        @sut.save()

      it 'should save the new flow data to redis', ->
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/my-instance-id/foo/config', '{}'
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/my-instance-id/foo/data', '{}'

    describe 'when config is missing', ->
      beforeEach ->
        @client = redis.createClient()
        sinon.stub @client, 'set'
        @flowData =
          foo:
            data: {}

        @sut = new ConfigrationSaverRedis flowId: 'some-other-flow-uuid', instanceId: 'my-instance-id', flowData: @flowData, {client: @client}
        @sut.save()

      it 'should save the new flow data to redis', ->
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/my-instance-id/foo/config', '{}'
        expect(@client.set).to.have.been.calledWith 'some-other-flow-uuid/my-instance-id/foo/data', '{}'
