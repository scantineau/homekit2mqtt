# from https://codefresh.io/blog/node_docker_multistage/

#
# ---- Base Node ----
FROM  mhart/alpine-node:8 AS base
# install node
RUN apk add --no-cache tini avahi-compat-libdns_sd
# set working directory
WORKDIR /root/app
# Set tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]
# copy project file
COPY package.json .
COPY package-lock.json .
 
#
# ---- Dependencies ----
FROM base AS dependencies
RUN apk add --no-cache python build-base
#RUN apk add --no-cache libffi-dev openssl-dev avahi-compat-libdns_sd avahi-dev 
RUN apk add --no-cache libffi-dev openssl-dev avahi-dev 
#RUN apk add --no-cache libsodium libtool autoconf automake
# install node packages
RUN npm set progress=false && npm config set depth 0
RUN npm i --unsafe-perm -only=production 
# copy production node_modules aside
RUN cp -R node_modules prod_node_modules
# install ALL node_modules, including 'devDependencies'
#RUN npm --unsafe-perm install

#
# ---- Release ----
FROM mhart/alpine-node:8
WORKDIR /root/app
# copy production node_modules
COPY --from=dependencies /root/app/prod_node_modules ./node_modules
# copy app sources
COPY package.json .
COPY config.js .
COPY index.js .
COPY services.json .
COPY accessories .
EXPOSE 51826
EXPOSE 51888
VOLUME ["/data"]
CMD ./index.js 