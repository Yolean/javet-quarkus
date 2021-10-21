# Javet + Quarkus experiment

See https://github.com/caoccao/Javet/issues/107

```
BUILDER=javet-quarkus-builder-image:local
docker build -t $BUILDER ./builder-image
./mvnw package -Pnative -Dquarkus.native.container-build=true -Dquarkus.native.builder-image=$BUILDER
```
