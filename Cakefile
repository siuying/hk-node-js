express           = require 'express'
ejs               = require 'ejs'
ISODate           = require 'isodate'

{FacebookService} = require './lib/facebook_service'
{PostService}    = require './lib/post_service'

groupId     = process.env.FB_GROUP_ID ? "133426573417117"
accessToken = process.env.FB_GRAPH_TOKEN

mongo_url   = process.env.MONGOHQ_URL

task 'import', 'fetch facebook update and insert into mongo', (options) ->
  fb        = new FacebookService accessToken
  mongo     = new PostService mongo_url

  mongo.importFacebook fb, groupId, (error, records) =>
    if error
      console.log("Failed saving to mongo", error)
    else
      console.log("#{records.length} saved.")
    mongo.close()

task 'export', "export mongo database", (options) ->
  mongo     = new PostService mongo_url
  mongo.findAll (error, posts) =>
    if error
      console.log("error saving post: ", error)
    else
      console.log("#{posts.length} records saved")

    mongo.close()