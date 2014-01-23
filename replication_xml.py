import argparse, urllib2, sys, gzip
from cStringIO import StringIO


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--hostport')
    parser.add_argument('--dataset')
    parser.add_argument('--start')
    args = parser.parse_args()

    ext = {
        'minute': 'osc.gz',
        'changesets': 'osm.gz',
    }[args.dataset]

    id = int(args.start)
    while True:
        url = "http://%s/replication/%s/%s.%s" % (
            args.hostport,
            args.dataset,
            encode_id(id),
            ext
        )
        try:
            f = urllib2.urlopen(url)
            gzipped = f.read()
            gzip_file = gzip.GzipFile(fileobj=StringIO(gzipped))
            data = gzip_file.read()
            sys.stdout.write(data)
            id += 1
        except urllib2.HTTPError as e:
            if e.code == 404:
                sys.stderr.write("Done. (We got a 404.)\n")
                return


def encode_id(id):
    s = str(id).rjust(9, '0')
    return '/'.join([s[0:3], s[3:6], s[6:9]])


if __name__ == '__main__':
  main()
