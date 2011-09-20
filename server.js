(function() {
  var FacebookService, PostService, accessToken, app, ejs, express, fb, groupId, importFacebook, lastImportTime, mongo, mongoUrl, port, _ref;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  express = require('express');
  ejs = require('ejs');
  FacebookService = require('./lib/facebook_service').FacebookService;
  PostService = require('./lib/post_service').PostService;
  port = process.env.PORT || 3000;
  mongoUrl = process.env.MONGOHQ_URL;
  groupId = (_ref = process.env.FB_GROUP_ID) != null ? _ref : "133426573417117";
  accessToken = process.env.FB_GRAPH_TOKEN;
  mongo = new PostService(mongoUrl);
  fb = new FacebookService(accessToken);
  app = express.createServer(express.logger());
  app.use(express.static("" + __dirname + "/public"));
  app.get('/', function(req, res) {
    var feeds;
    return feeds = mongo.findAll(__bind(function(error, feeds) {
      var data;
      if (error) {
        console.log(error);
        return res.send("Error contacting mongo: " + error.message);
      } else {
        data = feeds;
        return res.render('index.ejs', {
          data: data
        });
      }
    }, this));
  });
  app.listen(port, function() {
    return console.log("Listening on " + port);
  });
  lastImportTime = null;
  importFacebook = __bind(function() {
    var timestamp;
    if (lastImportTime) {
      timestamp = parseInt("" + (lastImportTime.valueOf() / 1000));
      console.log("import facebook messages since " + lastImportTime);
    } else {
      console.log("import facebook messages");
    }
    return mongo.importFacebook(fb, groupId, timestamp, __bind(function(error, records) {
      if (error) {
        return console.log("Failed saving to mongo", error);
      } else {
        console.log("" + records.length + " saved.");
        return lastImportTime = new Date();
      }
    }, this));
  }, this);
  setInterval(importFacebook, 1000 * 60 * 5);
  importFacebook();
}).call(this);
