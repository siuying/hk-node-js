express           = require 'express'
ejs               = require 'ejs'
{FacebookService} = require './lib/facebook_service'
{PostService}    = require './lib/post_service'

# Configuration
port          = process.env.PORT || 3000
mongoUrl      = process.env.MONGOHQ_URL
groupId       = process.env.FB_GROUP_ID ? "133426573417117"
accessToken   = process.env.FB_GRAPH_TOKEN
PAGINATE_WINDOW = process.env.PAGINATE_WINDOW ? 3
POST_PER_PAGE   = process.env.POST_PER_PAGE ? 10

# Setup services
mongo         = new PostService mongoUrl
fb            = new FacebookService accessToken
app           = express.createServer express.logger()
app.use express.static("#{__dirname}/public")

handleIndexPages = (req, res) ->
  @currentPage = req.params.page ? "1"
  @postPerPage = POST_PER_PAGE

  mongo.count (error, postCount) =>
    @postCount   = postCount
    @pageCount   = Math.ceil(@postCount / @postPerPage)
    @pagination  = [(Math.max(1, @currentPage-PAGINATE_WINDOW))..(Math.min(@pageCount, @currentPage+PAGINATE_WINDOW))]

    @isFirstPage = @currentPage == "1"
    @isLastPage  = parseInt(@currentPage) == @pageCount

    if error
      console.log error
      res.send "Error contacting mongo: #{error.message}"
      return

    mongo.findAll postPerPage, currentPage, (error, feeds) => 
      if error
        console.log error
        res.send "Error contacting mongo: #{error.message}"
      else
        
        @data     = feeds
        res.render 'index.ejs', {@data, @pageCount, @currentPage, @isFirstPage, @isLastPage, @pagination}

# Handle Requests
app.get '/', (req, res) ->
  handleIndexPages req, res
  
app.get '/page/:page', (req, res) ->
  handleIndexPages req, res

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