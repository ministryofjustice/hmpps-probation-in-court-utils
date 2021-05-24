# court-case-source
### A tool for testing the prepare-a-case stack

## Quickstart

Run `./subscribe-to-topic --email <your@email.address>` to subscribe to events from the `court-case-events-topic` SNS topic

Run `./populate.bash` to push some cases to the `court-case-events-topic` SNS topic

Run `./check-matcher-queue.bash` to check if there are any messages on the court-case-matcher queue

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
