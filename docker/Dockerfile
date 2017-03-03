# Dockerfile to create our app

FROM node:argon
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app/package
ADD app-1.0.0.tgz /usr/src/app/
RUN npm install
EXPOSE 3000
ENV NODE_ENV production
CMD [ "npm", "start" ]
