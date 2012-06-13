#!/bin/bash
set -e

VERSION="3.5.0"
USER_VERSION="-ts1"
MIRROR="http://apache.mirror.rbftpnetworks.com/lucene/solr"

mkdir -p build
cd build

tarball="apache-solr-$VERSION.tgz"
if [ ! -f $tarball ]; then
  curl -O "$MIRROR/$VERSION/$tarball"
fi
tar zxf $tarball
cd "apache-solr-$VERSION"

for d in solr webapps etc; do
  mkdir -p installdir/opt/solr/$d
done
for d in var/solr/data var/log/solr etc/solr etc/init; do
  mkdir -p installdir/$d
done

cat > installdir/etc/init/solr.conf <<END
start on runlevel [2345]
stop on runlevel [06]

script
  cd /opt/solr
  exec sudo -u solr java \\
    -Xms128M \\
    -Xmx512m \\
    -XX:+UseConcMarkSweepGC \\
    -XX:+UseParNewGC \\
    -Dsolr.solr.home=/opt/solr/solr \\
    -Djava.util.logging.config.file=/opt/solr/etc/logging.properties \\
    -jar /opt/solr/start.jar
end script
END

cat > installdir/opt/solr/etc/logging.properties <<END
.level = INFO
handlers = java.util.logging.FileHandler
java.util.logging.FileHandler.pattern = /var/log/solr/solr.log
java.util.logging.FileHandler.level = ALL
java.util.logging.FileHandler.formatter = java.util.logging.SimpleFormatter
END

cat > preinstall_script <<END
#!/bin/bash
adduser --system --group --no-create-home --disabled-password --disabled-login solr
END

cat > postinstall_script <<END
#!/bin/bash

for d in /opt/solr /var/solr /var/log/solr; do
  chown -R solr:solr \$d
done
END

for f in lib etc webapps start.jar; do
  cp -R example/$f installdir/opt/solr/
done

fpm \
  -s dir \
  -t deb \
  -n ts-solr \
  -p solr-VERSION_ARCH.deb \
  -v $VERSION${USER_VERSION} \
  -C installdir \
  -a all \
  -d java6-runtime-headless \
  --pre-install preinstall_script \
  --post-install postinstall_script \
  opt/solr var/solr etc/solr etc/init

mkdir -p ../../debs
mv *.deb ../../debs/
