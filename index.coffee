_ = require 'lodash'

class ConfigrationSaverRedis
  constructor: (@options, dependencies={}) ->
    {@flowId, @instanceId, @flowData} = @options
    redis = require 'redis'
    {@client} = dependencies
    @client ?= redis.createClient()

  save: (callback) =>
    _.each @flowData, (nodeConfig, key) =>
      @client.set "#{@flowId}/#{@instanceId}/#{key}/data", JSON.stringify nodeConfig.data ? {}
      @client.set "#{@flowId}/#{@instanceId}/#{key}/config", JSON.stringify nodeConfig.config ? {}
    _.defer =>
      callback null

module.exports = ConfigrationSaverRedis
