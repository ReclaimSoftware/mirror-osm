{ReplicationFile} = require './replication_file'

class MinuteFile extends ReplicationFile

  osm_dir: () -> "minute"
  ext: () -> "osc.gz"


module.exports = {MinuteFile}
