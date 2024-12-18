# court-case-source
### A tool for testing the prepare-a-case stack, plus utility scripts for managing it.

## Prerequisites

These scripts assume that you have a number of common developer tools installed, most notably `kubectl` and `keytool`. The scripts will use your kubectl credentials for accessing protected resources so these must be set up for the scripts to work.

And you will need some or all of these tools, depending on the scripts you want to run:
- kubectl
- jq
- awscli
- [cloud-platform cli](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/cloud-platform-cli.html#the-cloud-platform-cli)
- keytool

## kubectl contexts
The scripts assume that you have contexts set up for the `live` cluster for each of the `court-probation-*` namespaces. Your `~/.kube/config` file should have a section which looks something like this:

```
contexts:
- context:
    cluster: live.cloud-platform.service.justice.gov.uk
    namespace: court-probation-dev
    user: <youruser>
  name: court-probation-dev
- context:
    cluster: live.cloud-platform.service.justice.gov.uk
    namespace: court-probation-preprod
    user: <youruser>
  name: court-probation-preprod
- context:
    cluster: live.cloud-platform.service.justice.gov.uk
    namespace: court-probation-prod
    user: <youruser>
  name: court-probation-prod
  ```

## Making changes

Feel free to add useful scripts relevant to the prepare-a-case stack and raise a PR to get them merged. Given the sensitive nature of the data these scripts handle please be very careful not to expose credentials or inadvertently add sensitive data to the repo. When downloading anything remotely sensitive make sure to place it in a temporary folder in a completely separate location to remove the risk of accidentally committing anything. `~/temp/` has been adopted as an informal standard for this purpose.  

Helpful messages for the user are always appreciated, as are emojis giving an at a glance idea of what's going on. Bash scripts can be dense and difficult to read so they also make good documentation. 

An example:

```
echo "✨ Creating a shiny new thing!"
```

## Quickstart

**Update:** Since the changes to move from long lived credentials to IRSA based auth, we need to create a service pod in the namespace and establish a bash session, using the script `setup-service-pod.bash` which would create a pod and opens a bash session which then can be used to run below scripts.
    By default, the service pod name is `hmpps-probation-in-coourt-utils` and namespace is `court-probation-dev` which can be overwritten by `setup-service-pod.bash --debug_pod_name your-own-debug-pod-name --namespace your-alternate-name-space` 

Run `./subscribe-to-topic.bash --email <your@email.address>` to subscribe to events from the `court-cases-topic` SNS topic

Run `./populate-cpg-sqs.bash` to push case lists to the `crime-portal-gateway-queue` (To push message to probation-in-court-team-development-crime-portal-gateway-queue)

Run `./populate-matcher-sns.bash` to push some cases to the `court-cases-topic` SNS topic

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


## Push messages to crime-portal-gateway SOAP endpoint in dev

curl -v -X POST -H "Content-Type: application/soap+xml" http://crime-portal-gateway/crime-portal-gateway/ws/ -d "@crime-portal-gateway/test-data/case-list-success-soap.xml"

## Reference Data

| Court             | Code          |
|-------------------|---------------|
| North Tyneside    | B10JQ         |
| Sheffield         | B14LO         |



| Offender          | PNC           | CRN       | Details |
|-------------------|---------------|-----------|---------|
| Arthur Morgan     | 2004/0046583U | X346204   |         |
| John Marston      | 2018/0000001Z | X346224   |         |
