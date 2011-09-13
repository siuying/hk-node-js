Mongo     = require('mongoskin')
ISODate   = require 'isodate'

class MongoService
  constructor: (url) ->
    @db = Mongo.db("#{url}?auto_reconnect")
    
  getCollection: ->
    @db.collection('posts')

  close: ->
    @db.close()

  findAll: (callback) ->
    @getCollection().open (error, collection) ->
      if error
        callback(error)
      else
        collection.find().toArray (error, posts) ->
          if error 
            callback(error)
          else 
            callback(null, posts)

  save: (posts, callback) ->
    # if posts is not an array, make it an array
    if typeof(posts.length) == "undefined"
      posts = [posts]
    
    # preprocess the posts
    for post in posts
      post._id = post.id

      post.created_at = ISODate("#{post.created_time[0..21]}:#{post.created_time[22..24]}")
      post.updated_at = ISODate("#{post.updated_time[0..21]}:#{post.updated_time[22..24]}")

      if post.comments == undefined 
        post.comments = []

      for comment in post.comments
        comment.created_at = ISODate("#{comment.created_time[0..21]}:#{comment.created_time[22..24]}")
        comment.updated_at = ISODate("#{comment.updated_time[0..21]}:#{comment.updated_time[22..24]}")
    
    # save posts
    @getCollection().open (error, collection) ->
      collection.insert posts, {}, (error, results) ->
        if error 
          callback(error)
        else 
          callback(null, results)

root = exports ? window
root.MongoService = MongoService