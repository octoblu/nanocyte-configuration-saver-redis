_ = require 'lodash'
class ConfigrationSaverRedis
  constructor: (@options, dependencies={}) ->
    {@client} = dependencies

  save: =>
    _.each @options.flowData, (nodeConfig, key) =>
      @client.set "#{@options.flowId}/#{key}/data", JSON.stringify nodeConfig.data ? {}
      @client.set "#{@options.flowId}/#{key}/config", JSON.stringify nodeConfig.config ? {}

module.exports = ConfigrationSaverRedis
