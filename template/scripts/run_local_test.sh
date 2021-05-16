#!/bin/bash
THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

CONTAINER=$(docker run \
  -p 9000:8080 \
  -d \
  -i $(image.image_uri_string))
echo "Local container $CONTAINER started"

INVOCATION_BODY=$(<"$THIS_DIR/test_invocation_body.json")
echo "Passing invocation body $INVOCATION_BODY"

EXPECTED_RESPONSE=$(lambda_function.test_invocation_response)
echo "Expecting response $EXPECTED_RESPONSE, waiting..."

RESPONSE=$(curl -XPOST \
  "http://localhost:9000/2015-03-31/functions/function/invocations" \
  --silent \
  -d "$INVOCATION_BODY") 

wait $!

if [ $RESPONSE -eq $EXPECTED_RESPONSE ]
then
  echo "Received $RESPONSE; Test passed"
else
  echo "Received $RESPONSE; Test failed"
fi

docker stop $CONTAINER &>/dev/null
echo "Local container $CONTAINER stopped"
