express       = require 'express'
ejs           = require 'ejs'
facebook      = require 'facebook-graph'

groupId       = process.env.FB_GROUP_ID ? "133426573417117"
accessToken   = process.env.FB_GRAPH_TOKEN

app = express.createServer express.logger()
app.use express.static("#{__dirname}/public")

app.get '/', (req, res) ->
  graph   = new facebook.GraphAPI accessToken
  feeds   = graph.getObject "#{groupId}/feed", (error, feeds) => 
    if error
      console.log error
      res.send "Error contacting Facebook: #{error.message}"
    else
      data    = feeds.data
      paging  = feeds.paging
      res.render 'index.ejs', {data}

port = process.env.PORT || 3000
app.listen port, ->
  console.log "Listening on " + port