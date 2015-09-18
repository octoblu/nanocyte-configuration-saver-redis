_ = require 'lodash'
async = require 'async'
debug = require('debug')('nanocyte-configuration-saver-redis')

class ConfigrationSaverRedis
  constructor: (@client) ->

  save: (options, callback) =>
    {flowId, instanceId, flowData} = options
    debug "Saving #{flowId}/#{instanceId}"
    async.each _.keys(flowData), (key, next) =>
      nodeConfig = flowData[key]
      nodeConfig.data ?= {}
      nodeConfig.config ?= {}

      async.parallel [
        (cb) =>
          debug "set '#{flowId}/#{instanceId}/#{key}/data'", nodeConfig.data
          @client.set "#{flowId}/#{instanceId}/#{key}/data", JSON.stringify(nodeConfig.data), cb
        (cb) =>
          debug "set '#{flowId}/#{instanceId}/#{key}/config'", nodeConfig.config
          @client.set "#{flowId}/#{instanceId}/#{key}/config", JSON.stringify(nodeConfig.config), cb
      ], next
    , callback

module.exports = ConfigrationSaverRedis
