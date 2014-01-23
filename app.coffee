{respond_json, respond_error} = require 'rs-util'

module.exports = (app) ->
  {MinuteFile, ChangesetsFile} = app.Model.classes
  MinuteFile.keep_downloading()
  ChangesetsFile.keep_downloading()

  app.get '/', (req, res) ->
    res.render 'index'

  app.get '/replication/minute/:part1/:part2/:part3.osc.gz', (req, res) ->
    MinuteFile.serve_gz req, res

  app.get '/replication/changesets/:part1/:part2/:part3.osm.gz', (req, res) ->
    ChangesetsFile.serve_gz req, res
