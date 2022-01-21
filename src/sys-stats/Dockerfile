
###############################################################################
#### NODE BUILD STAGE
###############################################################################

FROM node:14.15.0-alpine3.12 AS build-stage

# install global packages
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ARG NODE_ENV=development


WORKDIR /app
RUN chown node:node ./

USER node

COPY --chown=node:node package* yarn.lock ./
RUN npm install --no-optional && npm cache clean --force

COPY public ./public
COPY --chown=node:node src ./src

ARG REACT_APP_API_HOST='http://localhost'
ARG REACT_APP_API_PORT='5000'
ENV REACT_APP_API_HOST=$REACT_APP_API_HOST
ENV REACT_APP_API_PORT=$REACT_APP_API_PORT

RUN npm run build

###############################################################################
#### NGINX SERVER
###############################################################################

FROM nginx:alpine

# TODO run as non root
# USER nginx
EXPOSE 80
EXPOSE 443
COPY --chown=nginx:nginx --from=build-stage /app/build /usr/share/nginx/html