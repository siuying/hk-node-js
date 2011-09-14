PAGINATE_WINDOW = process.env.PAGINATE_WINDOW ? 3
POST_PER_PAGE   = process.env.POST_PER_PAGE ? 10

class FeedController
  constructor: (@app, @mongo) ->

  configure: ->
    @app.get '/', (req, res) => 
      @index(req, res)

    @app.get '/page/:page', (req, res) => 
      @index(req, res)

  index: (req, res) ->
    @currentPage = req.params.page ? "1"
    @postPerPage = POST_PER_PAGE

    @mongo.count (error, postCount) =>
      @postCount   = postCount
      @pageCount   = Math.ceil(@postCount / @postPerPage)
      @pagination  = [(Math.max(1, @currentPage-PAGINATE_WINDOW))..(Math.min(@pageCount, @currentPage+PAGINATE_WINDOW))]

      @isFirstPage = @currentPage == "1"
      @isLastPage  = parseInt(@currentPage) == @pageCount

      if error
        console.log error
        res.send "Error contacting mongo: #{error.message}"
        return

      @mongo.findAll @postPerPage, @currentPage, (error, feeds) => 
        if error
          console.log error
          res.send "Error contacting mongo: #{error.message}"
        else
          @data     = feeds
          res.render 'index.ejs', {@data, @pageCount, @currentPage, @isFirstPage, @isLastPage, @pagination}

root = exports ? window
root.FeedController = FeedController