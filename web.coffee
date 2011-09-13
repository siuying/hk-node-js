express           = require 'express'
ejs               = require 'ejs'
{FacebookService} = require './lib/facebook_service'
{MongoService}    = require './lib/mongo_service'

# Configuration
port          = process.env.PORT || 3000
mongoUrl      = process.env.MONGOHQ_URL
groupId       = process.env.FB_GROUP_ID ? "133426573417117"
accessToken   = process.env.FB_GRAPH_TOKEN

# Setup services
fb            = new FacebookService accessToken
app           = express.createServer express.logger()
app.use express.static("#{__dirname}/public")

# Handle Requests
app.get '/', (req, res) ->
  feeds   = mongo.findAll (error, feeds) => 
    if error
      console.log error
      res.send "Error contacting mongo: #{error.message}"

    else
      data    = feeds
      res.render 'index.ejs', {data}

# Start Listening
app.listen port, ->
  console.log "Listening on " + port

lastImportTime = null

# Schedule Hourly Update
  
importFacebook = =>
  if lastImportTime
    timestamp = parseInt("" + (lastImportTime.valueOf() / 1000)) 
    console.log("import facebook messages since #{lastImportTime}")
  else
    console.log("import facebook messages")

  mongo  = new MongoService mongoUrl
  mongo.importFacebook fb, groupId, timestamp, (error, records) =>
    if error
      console.log("Failed saving to mongo", error)
    else
      console.log("#{records.length} saved.")
      lastImportTime = new Date()
    mongo.close()

setInterval importFacebook, 1000 * 60 * 60 * 24
importFacebook()