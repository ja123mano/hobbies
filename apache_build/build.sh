#!/bin/bash

MAVEN_VERSION=3.6.3
MAVEN_URL="http://mirror.cogentco.com/pub/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz"
HADOOP_VERSION=3.2.0
HADOOP_URL="https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION-src.tar.gz"
SPARK_VERSION="2.4.0"
SPARK_URL="https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION.tgz"

# Install Maven
echo $MAVEN_URL

if [ ! -f /tmp/apache-maven.tar.gz ]; then
curl -o /tmp/apache-maven.tar.gz $MAVEN_URL
fi

if [ -f /tmp/apache-maven.tar.gz ]; then
tar xzf /tmp/apache-maven.tar.gz --directory /opt
fi

M2_HOME="/opt/apache-maven-$MAVEN_VERSION"
PATH="${PATH}:/opt/apache-maven-$MAVEN_VERSION/bin"
ln -sf /opt/apache-maven-$MAVEN_VERSION/bin/mvn /usr/bin/mvn

export JAVA_HOME='/usr/lib/jvm/java-1.11.0-openjdk'

if [ -d hadoop-3.2.0-src ]; then
rm -rf hadoop-3.2.0-src
fi
# Build Hadoop
if [ ! -f hadoop-$HADOOP_VERSION-src.tar.gz ]; then
curl -LO $HADOOP_URL
fi

if [ -f hadoop-$HADOOP_VERSION-src.tar.gz ]; then
tar xzf hadoop-$HADOOP_VERSION-src.tar.gz
fi

cd hadoop-$HADOOP_VERSION-src && \
    patch -p1 < ../patches/hadoop/0001-Integrate-JDK11.patch && \
    patch -p1 < ../patches/hadoop/0001-Java_home-on-CLR.patch && \
    patch -p1 < ../patches/hadoop/HADOOP-11364.01.patch && \
    patch -p1 < ../patches/hadoop/0001-Stateless-v2.patch && \
    patch -p1 < ../patches/hadoop/0001-Change-protobuf-version.patch && \
    patch -p1 < ../patches/hadoop/protobuf3.patch && \
    patch -p1 < ../patches/hadoop/protobuf-3.6.1-hadoop-3.2.0-On-CLR.patch && \
    patch -p1 < ../patches/hadoop/0001-YARN-8498.-Yarn-NodeManager-OOM-Listener-Fails-Compi.patch

cd ../

cd hadoop-$HADOOP_VERSION-src && \
    mvn package -q -fae -Pnative -Pdist -DskipTests -Dtar -Danimal.sniffer.skip=true -Dmaven.javadoc.skip=true \
    -Djavac.version=11 -Dguava.version=19.0 -Dmaven.plugin-tools.version=3.6.0


