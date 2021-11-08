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
--files - May be used to specify individual files, defaults to all the files related to the script being used
--cases_path - relative to the "base-path" which is at ./cases/$namespace/common-platform-hearings/, a path to files to be processed. See examples below. When cases_path is passed with this parameter, the script will recurse up to a maximum depth of 10. 
 
```

Example 
```
./populate-matcher-sns-cp.bash --files hearing-bloggs.json
./populate-matcher-sns-cp.bash --generate_ids "false" --cases_path "sit/CONFIRM_UPDATE/B01DU00/"
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
