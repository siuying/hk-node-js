express           = require 'express'
ejs               = require 'ejs'
{FacebookService} = require './lib/facebook_service'

# Configuration
groupId       = process.env.FB_GROUP_ID ? "133426573417117"
accessToken   = process.env.FB_GRAPH_TOKEN
port          = process.env.PORT || 3000

# Setup services
fbService     = new FacebookService accessToken
app           = express.createServer express.logger()
app.use express.static("#{__dirname}/public")

# Handle Requests
app.get '/', (req, res) ->
  feeds   = fbService.getFeed groupId, (error, feeds) => 
    if error
      console.log error
      res.send "Error contacting Facebook: #{error.message}"
    else
      data    = feeds.data
      paging  = feeds.paging
      res.render 'index.ejs', {data}

# Start Listening
app.listen port, ->
  console.log "Listening on " + port