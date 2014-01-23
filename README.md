**Maintain a mirror of the OSM dataset**


### Developing

    cd mirror-osm && rs-dev --data-dir=...

Downloading runs automatically in the background.


### Paths

    /
    /replication/minute/000/123/456.osc.gz
    /replication/changesets/000/123/456.osc.gz


### XML stream

    python replication_xml.py \
      --hostport localhost:3000 \
      --dataset minute \
      --start 1

...keeps `GET`ing, gunzip-ing, and writing to stdout at > 100 MB/s.


### Upstream data

    http://planet.openstreetmap.org/replication/minute/000/123/456.osc.gz
    http://planet.openstreetmap.org/replication/changesets/000/123/456.osc.gz


### LevelDB schema

    ['minute_files', id]            -> "{...}"
    ['minute_files_desc', id_desc]  -> "{...}"
    ['minute.osc.gz', id_asc]       -> .osc.gz

    ['changesets_files', id]            -> "{...}"
    ['changesets_files_desc', id_desc]  -> "{...}"
    ['changesets.osm.gz', id_asc]       -> .osm.gz

...where key parts are joined by `":"`

and `id` is `123456` for `000/123/456`

and `id_desc` is `1e9 - 123456` for `000/123/456`

and `id_asc` is `000123456` for `000/123/456`.


### [License: MIT](LICENSE.txt)
