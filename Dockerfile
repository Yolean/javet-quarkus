FROM maven:3.8.1-adoptopenjdk-11@sha256:34bd76497d79aeda09b3c69db6af1633e3c155b45dae771f0855824b4dfc2948 as maven

FROM quay.io/quarkus/ubi-quarkus-mandrel:21.2.0.1-Final-java11@sha256:aa9b3d4e0ebf86da388c7ba4f98700324a17f351f02e571065e823b261a861cd as mandrel

FROM ubuntu:20.04@sha256:626ffe58f6e7566e00254b638eb7e0f3b11d4da9675088f4781a50ae288f3322 as builder

RUN set -ex; \
  export DEBIAN_FRONTEND=noninteractive; \
  runDeps='libsnappy1v5 libsnappy-jni liblz4-1 liblz4-jni libzstd1'; \
  buildDeps='gcc g++ libc-dev make zlib1g-dev libsnappy-dev liblz4-dev libzstd-dev unzip'; \
  apt-get update && apt-get install -y $runDeps $buildDeps --no-install-recommends; \
  \
  echo "With https://github.com/caoccao/Javet/discussions/26" \
  add-apt-repository ppa:ubuntu-toolchain-r/test \
  apt-get install gcc-7 g++-7 gcc-8 g++-8 gcc-9 g++-9 -y \
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9 --slave /usr/bin/gcov gcov /usr/bin/gcov-9 \
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 80 --slave /usr/bin/g++ g++ /usr/bin/g++-8 --slave /usr/bin/gcov gcov /usr/bin/gcov-8 \
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 70 --slave /usr/bin/g++ g++ /usr/bin/g++-7 --slave /usr/bin/gcov gcov /usr/bin/gcov-7 \
  \
  rm -rf /var/lib/apt/lists; \
  rm -rf /var/log/dpkg.log /var/log/alternatives.log /var/log/apt /root/.gnupg

COPY --from=maven /usr/share/maven /usr/share/maven
COPY --from=mandrel /opt/mandrel /opt/mandrel

ENV \
  CI=true \
  GRAALVM_HOME=/opt/mandrel \
  JAVA_HOME=/opt/mandrel \
  MAVEN_HOME=/usr/share/maven \
  MAVEN_CONFIG=/home/nonroot/.m2 \
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/share/maven/bin:/opt/mandrel/bin

# docker inspect quay.io/quarkus/ubi-quarkus-mandrel:21.2.0.1-Final-java11
RUN grep 'quarkus:x:1001' /etc/passwd || \
  echo 'quarkus:x:1001:65534:Quarkus:/home/quarkus:/usr/sbin/nologin' >> /etc/passwd && \
  mkdir -p /home/quarkus && touch /home/quarkus/.bash_history && chown -R 1001:65534 /home/quarkus
USER 1001:nogroup
ENTRYPOINT ["native-image"]
#VOLUME /project
WORKDIR /project

FROM builder as build
COPY pom.xml .
RUN set -e; \
  mkdir -p src/test/java/org; \
  echo 'package org; public class T { @org.junit.jupiter.api.Test public void t() { } }' > src/test/java/org/T.java; \
  mvn --batch-mode package; \
  mvn --batch-mode package -Pnative -Dquarkus.native.additional-build-args=--dry-run \
    || echo "... Build error is expected. Caching dependencies."; \
  rm -r src;
COPY --chown=quarkus . .
RUN set -e; \
  cd src/main/resources; \
  unzip $HOME/.m2/repository/com/caoccao/javet/javet/1.0.1/javet-1.0.1.jar '*.so'
RUN ["mvn", "package", "-Pnative"]
RUN ls -lR /tmp/javet

FROM builder as runtime
COPY --from=build /project/target/javet-quarkus-*-runner /usr/local/bin/quarkus
ENTRYPOINT ["/usr/local/bin/quarkus", "-Djava.util.logging.manager=org.jboss.logmanager.LogManager"]
USER nobody:nogroup

COPY --from=build --chown=nobody:nogroup /tmp/javet /tmp/javet
