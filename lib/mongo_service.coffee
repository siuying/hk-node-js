Mongo     = require 'mongoskin'
ISODate   = require 'isodate'
{_}       = require 'underscore'

class MongoService
  constructor: (url) ->
    @db = Mongo.db("#{url}?auto_reconnect")
    @db.collection('posts').ensureIndex([['facebook_id', 1]], true, -> )

  close: ->
    @db.close()

  findAll: (callback) ->
    @db.collection('posts').open (error, collection) ->
      if error
        callback(error)
      else
        collection.find().toArray (error, posts) ->
          if error 
            callback(error)
          else 
            callback(null, posts)

  # save posts to database, update records as needed
  save: (posts, callback) ->
    # if posts is not an array, make it an array
    if typeof(posts.length) == "undefined"
      posts = [posts]
    
    # preprocess the posts
    counter = 0
    for post in posts
      counter += 1
      console.log("(#{counter}) preprocessing message: #{post.id}")
      
      post.facebook_id = post.id
      post._id = post.id
      delete post.id

      post.created_at = ISODate("#{post.created_time[0..21]}:#{post.created_time[22..24]}")
      delete post.created_time if post.created_time
      
      post.updated_at = ISODate("#{post.updated_time[0..21]}:#{post.updated_time[22..24]}") if post.updated_time
      delete post.updated_time if post.updated_time
      
      if post.comments == undefined 
        post.comments = []

      for comment in post.comments
        comment.created_at = ISODate("#{comment.created_time[0..21]}:#{comment.created_time[22..24]}") if comment.created_time
        comment.updated_at = ISODate("#{comment.updated_time[0..21]}:#{comment.updated_time[22..24]}") if comment.updated_time

    # save posts
    @db.collection('posts').open (error, collection) =>
      postCount = posts.length
      counter   = 0
      
      if posts.length == 0
        callback(null, posts)
      else    
        for idx, post of posts        
          collection.save post, {safe: true, upsert: true}, (error, result) ->
            counter++
            if error
              callback(error)
            else if counter == postCount
              callback(null, posts)
  
  importFacebook: (fb, groupId, since, callback) ->
    # fetch all feeds
    all_feeds = []

    # create a fetch callback: if more pages available, fetch them
    onFeedFetched = (error, feeds) => 
      if error
        console.log error
        console.log "Error contacting Facebook: #{error.message}"
      else
        data    = feeds.data
        paging  = feeds.paging

        all_feeds.push(data)
        all_feeds = _.flatten(all_feeds)

        # fetch more if needed
        if data.length > 0 && paging?.next
          last_feed = data[data.length-1]
          last_feed_create_datestr = "#{last_feed.created_time[0..21]}:#{last_feed.created_time[22..24]}"
          last_feed_create_date    = ISODate(last_feed_create_datestr)
          timestamp = last_feed_create_date.valueOf() / 1000

          console.log("fetch message before: #{last_feed_create_date}")
          fb.getFeed groupId, {until: timestamp, since: since}, onFeedFetched

        else
          @save all_feeds, callback

    # fetch first page
    console.log("fetch message ...")
    fb.getFeed groupId, {since: since}, onFeedFetched

root = exports ? window
root.MongoService = MongoService