express           = require 'express'
ejs               = require 'ejs'
{MongoService}    = require './lib/mongo_service'

# Configuration
port          = process.env.PORT || 3000
mongo_url     = process.env.MONGOHQ_URL

# Setup services
mongo         = new MongoService mongo_url
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