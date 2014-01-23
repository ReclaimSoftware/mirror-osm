{Model} = require './model'
{get, respond_error, respond_not_found, intervalSet, rjust, lsplit_to_fixed_sized_chunks} = require 'rs-util'

class ReplicationFile extends Model

  id_asc: () -> rjust ("" + @id), 9, '0'

  id_desc: () -> "" + (1e9 - @id)

  fetch_gz: (c) -> ReplicationFile.db.get @gz_key(), c

  gz_key: () -> "#{@osm_dir()}.#{@ext()}:#{@id_asc()}"

  gz_url: () -> "http://planet.openstreetmap.org#{@gz_path()}"

  gz_path: () ->
    seq_with_slashes = lsplit_to_fixed_sized_chunks(@id_asc(), 3).join('/')
    "/replication/#{@osm_dir()}/#{seq_with_slashes}.#{@ext()}"

  @serve_gz: (req, res) ->
    {part1, part2, part3} = req.params
    id = parseInt (part1 + part2 + part3), 10
    file = new @ {id}
    file.fetch_gz (e, data) ->
      if e
        return respond_not_found res if e.notFound
        return respond_error res, e
      res.writeHead 200, {
        'Content-Type': 'application/x-gzip'
        'Content-Length': data.length
      }
      res.end data

  @keep_downloading: () ->
    intervalSet 1000, () =>
      if not @_downloading
        @_get_next()

  @_get_next: (callback=(->)) ->

    @_downloading = true
    c = (e, file) =>
      @_downloading = false
      callback e, file

    @_get_next_sequence_number (e, sequence_number) =>
      return c e if e
      file = new @ {
        id: sequence_number
        requested_at: new Date().getTime()
      }
      get 200, file.gz_url(), (e, res, data) =>
        return c e if e

        # https://github.com/ReclaimSoftware/rs-leveldb-wrapper/issues/1
        data = EMPTY_FILE_GZIP if data.length == 0

        date = new Date res.headers['last-modified']
        return c new Error "Invalid Date" if date.toString() == 'Invalid Date'
        file.set {
          created_at: date.getTime()
          gz_size: data.length
        }
        rows = [
          [file.gz_key(), data]
          ["#{@get_plural()}:#{file.id}", JSON.stringify file]
          ["#{@get_plural()}_desc:#{file.id_desc()}", JSON.stringify file]
        ]
        ReplicationFile.db.put_batch rows, (e) =>
          return c e if e
          console.log "#{file.gz_path()} saved."
          c null, file

  @_get_next_sequence_number: (c) ->
    ReplicationFile.db.get_range {prefix: "#{@get_plural()}_desc:", limit: 1}, (e, rows) =>
      return c e if e
      return c null, FIRST_SEQUENCE_NUMBER if rows.length == 0
      [key] = rows[0]
      last_sequence_number = decode_id_desc key.toString().split(':')[1]
      c null, (last_sequence_number + 1)


FIRST_SEQUENCE_NUMBER = 1
EMPTY_FILE_GZIP = new Buffer '1F8B08006F32E152000303000000000000000000', 'hex'


decode_id_desc = (sequence_number_desc) ->
  n = parseInt sequence_number_desc, 10
  1e9 - sequence_number_desc


module.exports = {ReplicationFile}
