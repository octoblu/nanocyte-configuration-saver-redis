_ = require 'lodash'
class ConfigrationSaverRedis
  constructor: (@options, dependencies={}) ->
    {@flowId, @instanceId, @flowData} = @options
    {@client} = dependencies

  save: =>
    _.each @flowData, (nodeConfig, key) =>
      @client.set "#{@flowId}/#{@instanceId}/#{key}/data", JSON.stringify nodeConfig.data ? {}
      @client.set "#{@flowId}/#{@instanceId}/#{key}/config", JSON.stringify nodeConfig.config ? {}

module.exports = ConfigrationSaverRedis
