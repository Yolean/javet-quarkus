# Javet + Quarkus experiment

See https://github.com/caoccao/Javet/issues/107


By default, quarkus builds to local ./target

```
BUILDER=javet-quarkus-builder-image:local
# Build without build context
cat ./Dockerfile | DOCKER_BUILDKIT=1 docker build -t $BUILDER --target=builder -
./mvnw package -Pnative -Dquarkus.native.container-build=true -Dquarkus.native.builder-image=$BUILDER
```

Build runtime image while still depending on local mvn build
```
# Build avoiding Quarkus' inverted default .dockerignore
DOCKER_BUILDKIT=1 docker build -t javet-quarkus:local .
```
