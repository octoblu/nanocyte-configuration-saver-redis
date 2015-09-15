_ = require 'lodash'

class ConfigrationSaverRedis
  constructor: (@client) ->

  save: (options, callback) =>
    {flowId, instanceId, flowData} = options

    _.each flowData, (nodeConfig, key) =>
      @client.set "#{flowId}/#{instanceId}/#{key}/data", JSON.stringify nodeConfig.data ? {}
      @client.set "#{flowId}/#{instanceId}/#{key}/config", JSON.stringify nodeConfig.config ? {}
    _.defer =>
      callback null

module.exports = ConfigrationSaverRedis
