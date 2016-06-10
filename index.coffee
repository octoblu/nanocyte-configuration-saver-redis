_ = require 'lodash'
async = require 'async'
debug = require('debug')('nanocyte-configuration-saver-redis')

class ConfigrationSaverRedis
  constructor: (@client) ->

  stop: (options, callback) =>
    {flowId} = options
    @client.exists "#{flowId}-stop", (error, result) =>
      return callback error if error?
      return callback null unless result > 0
      @client.rename "#{flowId}-stop", flowId, callback

  save: (options, callback) =>
    {flowId, instanceId, flowData} = options
    debug "Saving #{flowId} #{instanceId}"
    async.each _.keys(flowData), (key, next) =>
      nodeConfig = flowData[key]
      nodeConfig.data ?= {}
      nodeConfig.config ?= {}

      async.parallel [
        (cb) =>
          debug "hset #{flowId} '#{instanceId}/#{key}/data'", nodeConfig.data
          @client.hset flowId, "#{instanceId}/#{key}/data", JSON.stringify(nodeConfig.data), cb
        (cb) =>
          debug "hset #{flowId} '#{instanceId}/#{key}/config'", nodeConfig.config
          @client.hset flowId, "#{instanceId}/#{key}/config", JSON.stringify(nodeConfig.config), cb
      ], next
    , callback

  saveIotApp: (options, callback) =>
    {appId, config, configSchema, flowId, instanceId, version} = options
    debug "Saving IoTApp #{flowId} #{instanceId}"
    @client.hset flowId, "#{instanceId}/iot-app/config", JSON.stringify({ appId, version, configSchema, config}), callback

    callback

module.exports = ConfigrationSaverRedis
