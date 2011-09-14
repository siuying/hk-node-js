express           = require 'express'
ejs               = require 'ejs'
{FacebookService} = require './lib/facebook_service'
{PostService}    = require './lib/post_service'

# Configuration
port          = process.env.PORT || 3000
mongoUrl      = process.env.MONGOHQ_URL
groupId       = process.env.FB_GROUP_ID ? "133426573417117"
accessToken   = process.env.FB_GRAPH_TOKEN

# Setup services
mongo         = new PostService mongoUrl
fb            = new FacebookService accessToken
app           = express.createServer express.logger()
app.use express.static("#{__dirname}/public")

# Handle Requests
app.get '/', (req, res) ->
  page    = req.params.page ? "1"
  mongo.findAll 10, page, (error, feeds) => 
    if error
      console.log error
      res.send "Error contacting mongo: #{error.message}"

    else
      console.log("feeds: ", feeds)
      data    = feeds
      res.render 'index.ejs', {data}

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