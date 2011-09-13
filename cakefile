express           = require 'express'
ejs               = require 'ejs'
ISODate           = require 'isodate'
{_}               = require 'underscore'

{FacebookService} = require './lib/facebook_service'
{MongoService}    = require './lib/mongo_service'

groupId     = process.env.FB_GROUP_ID ? "133426573417117"
accessToken = process.env.FB_GRAPH_TOKEN

mongo_url   = process.env.MONGOHQ_URL

task 'import', 'fetch facebook update and insert into mongo', (options) ->
  fb        = new FacebookService accessToken
  mongo     = new MongoService mongo_url

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
        fb.getFeed groupId, {until: timestamp}, onFeedFetched
        
      else
        mongo.save all_feeds, (error, records) =>
          if error
            console.log("Failed saving to mongo", error)
          else
            console.log("#{records.length} saved.")

          mongo.close()

  # fetch first page
  console.log("fetch message ...")
  fb.getFeed groupId, null, onFeedFetched

task 'export', "export mongo database", (options) ->
  mongo     = new MongoService mongo_url
  mongo.findAll (error, posts) =>
    if error
      console.log("error saving post: ", error)
    else
      console.log("#{posts.length} records saved")

    mongo.close()