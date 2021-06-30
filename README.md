# court-case-source
### A tool for testing the prepare-a-case stack

## Prerequisites

You will need both the [Cloud-Platform CLI](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/cloud-platform-cli.html#the-cloud-platform-cli) and the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html) installed to run these scripts. You will also need `jq`.

## Quickstart

Run `./subscribe-to-topic.bash --email <your@email.address>` to subscribe to events from the `court-case-events-topic` SNS topic

Run `./populate-cpg-sqs.bash` to push case lists to the `crime-portal-gateway-queue`

Run `./populate-matcher-sns.bash` to push some cases to the `court-case-events-topic` SNS topic

Run `./check-queue.bash` to check if there are any messages on the court-case-matcher queue

## Parameters

```
--namespace - Defaults to court-probation-dev
```


## Reference Data

| Court             | Code          |
|-------------------|---------------|
| North Tyneside    | B10JQ         |
| Sheffield         | B14LO         |



| Offender          | PNC           | CRN       | Details |
|-------------------|---------------|-----------|---------|
| Arthur Morgan     | 2004/0046583U | X346204   |         |
| John Marston      | 2018/0000001Z | X346224   |         |
