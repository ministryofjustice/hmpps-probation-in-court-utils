# crime-portal-gateway certificate management scripts

This folder contains a number of utility scripts for updating `crime-portal-gateway` certificates and keys, read the documentation [here](https://dsdmoj.atlassian.net/wiki/spaces/PIC/pages/3963617805/Crime+Portal+Certificate+Renewal) for more on this. 

See [../README.md](../README.md) for prerequisites.

## Usage

All of these scripts take an argument `--namespace {namespace}` which if not provided defaults to `court-probation-dev`. This is used both to identify the namespace to use if fetching or updating, and to ensure separate folders are used to keep the artefacts for each namespace separate. 
