#!/usr/bin/env bash
set -e
export TERM=ansi
export AWS_ACCESS_KEY_ID=foobar
export AWS_SECRET_ACCESS_KEY=foobar
export AWS_DEFAULT_REGION=eu-west-2
export PAGER=

aws --endpoint-url http://localhost:4566 sqs create-queue --queue-name crime-portal-gateway-queue.fifo --attributes "FifoQueue=true"
CCM_DLQ_ARN=$(aws --endpoint-url http://localhost:4566 sqs create-queue --queue-name court-case-matcher-dlq.fifo --attributes "FifoQueue=true" --output text)
QUEUE_URL=$(aws --endpoint-url http://localhost:4566 sqs create-queue --queue-name court-case-matcher-queue.fifo --attributes "FifoQueue=true" --output text)
QUEUE_ARN=$(aws sqs get-queue-attributes --queue-url ${QUEUE_URL} --attribute-names QueueArn --endpoint-url=http://localhost:4566)

# sleep 2
aws --endpoint-url=http://localhost:4566 sqs set-queue-attributes --queue-url "http://localhost:4566/000000000000/crime-portal-gateway-queue.fifo" --attributes '{"RedrivePolicy":"{\"maxReceiveCount\":\"1\", \"deadLetterTargetArn\":\"arn:aws:sqs:eu-west-2:000000000000:crime-portal-gateway-dlq.fifo\"}"}'
aws --endpoint-url=http://localhost:4566 sqs set-queue-attributes --queue-url "http://localhost:4566/000000000000/court-case-matcher-queue.fifo" --attributes '{"RedrivePolicy":"{\"maxReceiveCount\":\"1\", \"deadLetterTargetArn\":\"arn:aws:sqs:eu-west-2:000000000000:court-case-matcher-dlq.fifo\"}"}'

# # Create SNS topic
TOPIC_ARN=$(aws --endpoint-url http://localhost:4566 sns create-topic --output text --name court-cases-topic.fifo --attributes '{"FifoTopic":"true", "ContentBasedDeduplication":"true"}' --output text)

aws --endpoint-url http://localhost:4566 sns subscribe --topic-arn "$TOPIC_ARN" --protocol sqs --notification-endpoint "$QUEUE_ARN" --output text

echo "SQS and SNS Configured"
