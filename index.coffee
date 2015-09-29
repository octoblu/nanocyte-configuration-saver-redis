_ = require 'lodash'
async = require 'async'
debug = require('debug')('nanocyte-configuration-saver-redis')

class ConfigrationSaverRedis
  constructor: (@client) ->

  clear: (options, callback) =>
    {flowId} = options
    @client.del flowId, callback

  save: (options, callback) =>
    {flowId, instanceId, flowData} = options
    debug "Saving #{flowId}/#{instanceId}"
    async.each _.keys(flowData), (key, next) =>
      nodeConfig = flowData[key]
      nodeConfig.data ?= {}
      nodeConfig.config ?= {}

      async.parallel [
        (cb) =>
          debug "hset '#{flowId} #{instanceId}/#{key}/data'", nodeConfig.data
          @client.hset flowId, "#{instanceId}/#{key}/data", JSON.stringify(nodeConfig.data), cb
        (cb) =>
          debug "hset '#{flowId}/#{instanceId}/#{key}/config'", nodeConfig.config
          @client.hset flowId, "#{instanceId}/#{key}/config", JSON.stringify(nodeConfig.config), cb
      ], next
    , callback

module.exports = ConfigrationSaverRedis
