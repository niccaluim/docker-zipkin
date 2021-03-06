echo "*** Adding Cassandra deb source"
cat << EOF >> /etc/apt/sources.list
deb http://www.apache.org/dist/cassandra/debian 21x main
deb-src http://www.apache.org/dist/cassandra/debian 21x main
EOF

echo "*** Importing Cassandra deb keys"
gpg --keyserver keys.gnupg.net --recv-keys 749D6EEC0353B12C
gpg --export --armor 749D6EEC0353B12C | apt-key add -

echo "*** Installing Cassandra"
apt-get update
apt-get install -y cassandra procps wget

echo "*** Starting Cassandra"
sed -i s/Xss180k/Xss256k/ /etc/cassandra/cassandra-env.sh
/usr/sbin/cassandra
sleep 10

echo "*** Importing Scheme"
wget https://raw.github.com/openzipkin/zipkin/master/zipkin-cassandra/src/schema/cassandra-schema.txt
cassandra-cli -host localhost -port 9160 -f cassandra-schema.txt

echo "*** Stopping Cassandra"
killall java

mv /etc/cassandra/cassandra.yaml /etc/cassandra/cassandra.default.yaml

echo "*** Image build complete"
