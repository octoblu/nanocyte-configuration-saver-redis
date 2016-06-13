_     = require 'lodash'
Datastore = require 'meshblu-core-datastore'
mongojs = require 'mongojs'
Redis = require 'ioredis'
ConfigrationSaverRedis = require '../index'

describe 'ConfigrationSaverRedis', ->
  beforeEach (done) ->
    db = mongojs 'localhost/flow-config-test', ['instances']
    @datastore = new Datastore
      database: db
      collection: 'instances'
    db.instances.remove done

  beforeEach (done) ->
    @client = new Redis dropBufferSupport: true
    @client.on 'ready', done

  beforeEach ->
    @sut = new ConfigrationSaverRedis {@client, @datastore}

  describe '->stop', ->
    beforeEach (done) ->
      @client.hset 'some-flow-uuid-stop', 'foo', '{}', done

    describe 'when called with a flow', ->
      beforeEach (done) ->
        @sut.stop flowId: 'some-flow-uuid', done

      it 'should rename the flow-stop key to the flowUuid key', (done) ->
        @client.exists 'some-flow-uuid-stop', (error, exists) =>
          return done error if error?
          expect(exists).to.equal 0
          done()

      it 'should rename the flow-stop key to the flowUuid key', (done) ->
        @client.exists 'some-flow-uuid', (error, exists) =>
          return done error if error?
          expect(exists).to.equal 1
          done()

  describe '->save', ->
    describe 'when called with flow data', ->
      beforeEach (done) ->
        @flowData =
          router:
            config: {}
            data: {}

        @sut.save flowId: 'some-flow-uuid', instanceId: 'my-instance-id', flowData: @flowData, done

      it 'should save to mongo', (done) ->
        @datastore.findOne {flowId: 'some-flow-uuid', instanceId: 'my-instance-id'}, (error, {flowData}) =>
          return done error if error?
          expect(JSON.parse flowData).to.deep.equal @flowData
          done()

      it 'should save to redis', (done) ->
        @client.hget 'some-flow-uuid', 'my-instance-id/router/config', (error, data) =>
          return done error if error?
          expect(data).to.equal '{}'
          done()

    describe 'when called with a new set of flow data', ->
      beforeEach (done) ->
        @flowData =
          router:
            config: {}
            data: {}

        @sut.save flowId: 'other-flow-uuid', instanceId: 'my-instance-id', flowData: @flowData, done

      it 'should save the new flow data to redis', (done) ->
        @client.hget 'other-flow-uuid', 'my-instance-id/router/config', (error, data) =>
          return done error if error?
          expect(data).to.equal '{}'
          done()

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

      it 'should save the new flow data to redis', (done) ->
        fields = [
          'my-instance-id/some-node-uuid/data'
          'my-instance-id/router/config'
          'my-instance-id/router/data'
          'my-instance-id/some-node-uuid/config'
          'my-instance-id/meshblu-output/config'
          'my-instance-id/meshblu-output/data'
        ]
        @client.hmget 'other-flow-uuid', fields, (error, result) =>
          return done error if error?

          expect(result[0]).to.equal '{"cats":true}'
          expect(result[1]).to.equal '{"foo":"bar"}'
          expect(result[2]).to.equal '{"data":"something"}'
          expect(result[3]).to.equal '{}'
          expect(result[4]).to.equal '{}'
          expect(result[5]).to.equal '{}'
          done()

    describe 'when data is missing', ->
      beforeEach (done) ->
        @flowData =
          foo:
            config: {}

        @sut.save flowId: 'other-flow-uuid', instanceId: 'my-instance-id', flowData: @flowData, done

      it 'should save the new flow data to redis', (done) ->
        fields = [
          'my-instance-id/foo/config'
          'my-instance-id/foo/data'
          ]
        @client.hmget 'other-flow-uuid', fields, (error, result) =>
          return done error if error?

          expect(result[0]).to.equal '{}'
          expect(result[1]).to.equal '{}'
          done()

    describe 'when config is missing', ->
      beforeEach (done) ->
        @flowData =
          foo:
            data: {}

        @sut.save flowId: 'other-flow-uuid', instanceId: 'my-instance-id', flowData: @flowData, done

      it 'should save the new flow data to redis', (done) ->
        fields = [
          'my-instance-id/foo/config'
          'my-instance-id/foo/data'
          ]
        @client.hmget 'other-flow-uuid', fields, (error, result) =>
          return done error if error?

          expect(result[0]).to.equal '{}'
          expect(result[1]).to.equal '{}'
          done()

  describe '->linkToBluprint', ->
    describe 'when called with a config and configSchema', ->
      beforeEach (done) ->

        configSchema =
          type: 'object'
          properties:
            whatKindaTriggerDoYouWant:
              type: 'string'
              "x-node-map": [
                {id: '1418a3c0-2dd2-11e6-9598-13e1d65cd653', property: 'payloadType'}
              ]

        config = whatKindaTriggerDoYouWant: 'none'

        @iotAppConfig =
          flowId: 'empty-flow'
          instanceId: 'hi'
          appId: 'iot-app'
          version: '1.0.0'
          configSchema: configSchema,
          config: config

        @sut.linkToBluprint @iotAppConfig, done

      it 'should save to redis', (done) ->
        @client.hget 'empty-flow', 'hi/bluprint/config', (error, result) =>
          return done error if error?

          expect(result).to.equal JSON.stringify(_.pick @iotAppConfig, 'appId', 'version', 'configSchema', 'config')
          done()
