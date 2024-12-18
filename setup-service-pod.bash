#!/bin/bash
namespace=court-probation-dev

hostname=$(hostname)
# Read any named params
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi

  shift
done

set -o history -o histexpand
set -e
exit_on_error() {
    exit_code=$1
    last_command=${@:2}
    if [ $exit_code -ne 0 ]; then
        >&2 echo "💥 Last command:"
        >&2 echo "    \"${last_command}\""
        >&2 echo "❌ Failed with exit code ${exit_code}."
        >&2 echo "🟥 Aborting"
        exit $exit_code
    fi
}

debug_pod_name=hmpps-probation-in-court-utils-$namespace
echo "service pod name: $debug_pod_name"
service_pod_exists="$(kubectl get pods $debug_pod_name || echo 'NotFound')"

if [ "$local" = "true" ]
then
  echo "🏠 Running against localstack"
  MATCHER_TOPIC_ARN="arn:aws:sns:eu-west-2:000000000000:court-cases-topic.fifo"
  OPTIONS="--endpoint-url http://localhost:4566"
  AWS_ACCESS_KEY_ID=
  AWS_ACCESS_KEY_ID=
else
    if [[ ! $service_pod_exists =~ 'NotFound' ]]; then
      echo "$debug_pod_name exists signing into shell"
      kubectl exec -it -n $namespace $debug_pod_name -- sh
      exit 0
    fi
  # Get credentials and queue details from namespace secret
  echo "🔑 Getting matcher topic arn from secrets..."
  secret_json=$(cloud-platform decode-secret -s court-cases-topic -n $namespace --skip-version-check)
  export MATCHER_TOPIC_ARN=$(echo "$secret_json" | jq -r .data.topic_arn)

  echo "🔑 Getting matcher dlq arn from secrets..."
  secret_json=$(cloud-platform decode-secret -s court-case-matcher-queue-dead-letter-queue-credentials -n $namespace --skip-version-check)
  export MATCHER_DLQ_QUEUE_URL=$(echo "$secret_json" | jq -r .data.sqs_id)

  echo "🔑 Getting RDS instance from secrets ..."
  secret_json=$(cloud-platform decode-secret -s court-case-service-rds-instance-output -n $namespace --skip-version-check)
  export RDS_INSTANCE_IDENTIFIER=$(echo "$secret_json" | jq -r .data.rds_instance_address | sed s/[.].*//)

  echo "🔑 Getting crime portal gateway S3 bucket name from secrets..."
  secret_json=$(cloud-platform decode-secret -s crime-portal-gateway-s3-credentials -n $namespace  --skip-version-check)
  export CRIME_PORTAL_GATEWAY_BUCKET_NAME=$(echo "$secret_json" | jq -r .data.bucket_name)

  echo "🔑 Getting court case matcher queue url from secrets..."
  secret_json=$(cloud-platform decode-secret -s court-case-matcher-queue-credentials -n $namespace --skip-version-check)
  export MATCHER_QUEUE_URL=$(echo "$secret_json" | jq -r .data.sqs_id)

  echo "🔑 Getting crime portal gateway queue url for $namespace..."
  secret_json=$(cloud-platform decode-secret -s crime-portal-gateway-queue-credentials -n $namespace --skip-version-check)
  export CRIME_PORTAL_GATEWAY_QUEUE_URL=$(echo "$secret_json" | jq -r .data.sqs_id)

  echo "🔑 Getting redis arameters..."
  secret_json=$(cloud-platform decode-secret -s pac-elasticache-redis -n $namespace --skip-version-check)
  export REDIS_HOST=$(echo "$secret_json" | jq -r .data.primary_endpoint_address)
  export REDIS_AUTH_TOKEN=$(echo "$secret_json" | jq -r .data.auth_token)

  kubectl --namespace=$namespace --request-timeout='120s' run \
      --env "namespace=$namespace" \
      --env "MATCHER_TOPIC_ARN=$MATCHER_TOPIC_ARN" \
      --env "MATCHER_QUEUE_URL=$MATCHER_QUEUE_URL" \
      --env "MATCHER_DLQ_QUEUE_URL=$MATCHER_DLQ_QUEUE_URL" \
      --env "RDS_INSTANCE_IDENTIFIER=$RDS_INSTANCE_IDENTIFIER" \
      --env "CRIME_PORTAL_GATEWAY_BUCKET_NAME=$CRIME_PORTAL_GATEWAY_BUCKET_NAME" \
      --env "CRIME_PORTAL_GATEWAY_QUEUE_URL=$CRIME_PORTAL_GATEWAY_QUEUE_URL" \
      --env "REDIS_HOST=$REDIS_HOST" \
      --env "REDIS_AUTH_TOKEN=$RREDIS_AUTH_TOKEN" \
    -it --rm $debug_pod_name --image=quay.io/hmpps/hmpps-probation-in-court-utils:latest \
     --restart=Never --overrides='{ "spec": { "serviceAccount": "court-facing-api" } }'
fi

