_ = require 'lodash'
async = require 'async'
debug = require('debug')('nanocyte-configuration-saver-redis')

class ConfigrationSaverRedis
  constructor: ({@client, @datastore}) ->

  stop: (options, callback) =>
    {flowId} = options
    @client.exists "#{flowId}-stop", (error, result) =>
      return callback error if error?
      return callback null unless result > 0
      @client.rename "#{flowId}-stop", flowId, callback

  save: (options, callback) =>
    tasks = [
      async.apply @_saveMongo, options
      async.apply @_saveRedis, options
    ]
    async.series tasks, callback

  _saveMongo: (options, callback) =>
    {flowId, instanceId, flowData} = options
    flowData = JSON.stringify flowData
    @datastore.insert {flowId, instanceId, flowData}, callback

  _saveRedis: (options, callback) =>
    {flowId, instanceId, flowData} = options
    debug "Saving #{flowId} #{instanceId}"
    async.each _.keys(flowData), (key, next) =>
      nodeConfig = flowData[key]
      nodeConfig.data ?= {}
      nodeConfig.config ?= {}

      tasks = [
        async.apply @client.hset, flowId, "#{instanceId}/#{key}/data", JSON.stringify(nodeConfig.data)
        async.apply @client.hset, flowId, "#{instanceId}/#{key}/config", JSON.stringify(nodeConfig.config)
      ]

      async.parallel tasks, next
    , callback

  linkToBluprint: (options, callback) =>
    {appId, config, configSchema, flowId, instanceId, version} = options
    debug "linking to bluprint #{flowId} #{instanceId}"
    @client.hset flowId, "#{instanceId}/bluprint/config", JSON.stringify({ appId, version, configSchema, config}), callback

    callback

module.exports = ConfigrationSaverRedis
