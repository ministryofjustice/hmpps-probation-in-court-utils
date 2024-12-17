#!/usr/bin/env bash
set -e
export TERM=ansi
export AWS_ACCESS_KEY_ID=foobar
export AWS_SECRET_ACCESS_KEY=foobar
export AWS_DEFAULT_REGION=eu-west-2
export PAGER=

CPG_DLQ_ARN=$(aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name crime-portal-gateway-dlq --output text)
aws --endpoint-url http://localhost:4566 sqs create-queue --queue-name crime-portal-gateway-queue
CCM_DLQ_ARN=$(aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name court-case-matcher-dlq --output text)
QUEUE_ARN=$(aws --endpoint-url http://localhost:4566 sqs create-queue --queue-name court-case-matcher-queue --output text)

sleep 2
aws --endpoint-url=http://localhost:4566 sqs set-queue-attributes --queue-url "http://localhost:4566/queue/crime-portal-gateway-queue" --attributes '{"RedrivePolicy":"{\"maxReceiveCount\":\"1\", \"deadLetterTargetArn\":\"arn:aws:sqs:eu-west-2:000000000000:crime-portal-gateway-dlq\"}"}'
aws --endpoint-url=http://localhost:4566 sqs set-queue-attributes --queue-url "http://localhost:4566/queue/court-case-matcher-queue" --attributes '{"RedrivePolicy":"{\"maxReceiveCount\":\"1\", \"deadLetterTargetArn\":\"arn:aws:sqs:eu-west-2:000000000000:court-case-matcher-dlq\"}"}'

# Create SNS topic
TOPIC_ARN=$(aws --endpoint-url http://localhost:4566 sns create-topic --output text --name court-cases-topic --output text)
aws --endpoint-url http://localhost:4566 sns subscribe --topic-arn "$TOPIC_ARN" --protocol sqs --notification-endpoint "$QUEUE_ARN" --output text

echo "SQS and SNS Configured"
