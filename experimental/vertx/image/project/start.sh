export VERTICLE_NAME=`xmlstarlet sel -t -v "//*[local-name()='vertx.verticle']" /work/pom.xml`
exec vertx run $VERTICLE_NAME -cp /work/*