facebook = require 'facebook-graph'

class FacebookService
  constructor: (@accessToken) ->
    @graph = new facebook.GraphAPI(@accessToken)

  getFeed: (groupId, params={until: null, since: null}, callback) ->
    feeds = @graph.getObject "#{groupId}/feed", params, callback

root = exports ? window
root.FacebookService = FacebookService