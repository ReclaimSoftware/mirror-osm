{ReplicationFile} = require './replication_file'

class ChangesetsFile extends ReplicationFile

  osm_dir: () -> "changesets"
  ext: () -> "osm.gz"


module.exports = {ChangesetsFile}
