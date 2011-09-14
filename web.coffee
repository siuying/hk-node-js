express           = require 'express'
ejs               = require 'ejs'
{FacebookService} = require './lib/services/facebook_service'
{PostService}     = require './lib/services/post_service'
{FeedController}  = require './lib/controllers/feed_controller'

# Configuration
port          = process.env.PORT || 3000
mongoUrl      = process.env.MONGOHQ_URL
groupId       = process.env.FB_GROUP_ID ? "133426573417117"
accessToken   = process.env.FB_GRAPH_TOKEN

# Setup services
app           = express.createServer express.logger()
app.use express.static("#{__dirname}/public")

mongo         = new PostService mongoUrl
fb            = new FacebookService accessToken
controller    = new FeedController app, mongo

# setup feed controller
controller.configure()

# Start Listening
app.listen port, ->
  console.log "Listening on " + port

# Schedule import job every 5 minutes  
lastImportTime = null
importFacebook = =>
  if lastImportTime
    timestamp = parseInt("" + (lastImportTime.valueOf() / 1000)) 
    console.log("import facebook messages since #{lastImportTime}")
  else
    console.log("import facebook messages")

  mongo.importFacebook fb, groupId, timestamp, (error, records) =>
    if error
      console.log("Failed saving to mongo", error)
    else
      console.log("#{records.length} saved.")
      lastImportTime = new Date()

setInterval importFacebook, 1000 * 60 * 5
importFacebook()