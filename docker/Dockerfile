#!/bin/bash

# Licensed Materials - Property of IBM
# 5725-L30, 5725-Z22
#
# (C) Copyright IBM Corporation 2017
#
# All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.

# Dockerfile to create our app

FROM node:argon
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app/package
ADD app-1.0.0.tgz /usr/src/app/
RUN npm install
EXPOSE 3000
ENV NODE_ENV production
CMD [ "npm", "start" ]
