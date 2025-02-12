FROM ghcr.io/ministryofjustice/hmpps-devops-tools:latest

USER root
RUN apt-get update && apt-get install uuid-runtime redis-tools -y
MAINTAINER MoJ Digital, Probation in Court <probation-in-court-team@digital.justice.gov.uk>

ARG BUILD_NUMBER
ARG GIT_REF

ENV TZ=Europe/London
RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone

ENV BUILD_NUMBER=${BUILD_NUMBER:-1_0_0}
ENV GIT_REF=${GIT_REF:-dummy}

WORKDIR /app

COPY . .

ENV APP_VERSION=${BUILD_NUMBER}

USER 2000
