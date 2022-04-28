FROM node:16.11.0
# create destination directory
RUN mkdir -p /usr/src/dapp.gemnodes
WORKDIR /usr/src/dapp.gemnodes

RUN apt-get update && apt-get install git

# copy the app, note .dockerignore
COPY . /usr/src/dapp.gemnodes/

# RUN npm install --save-dev webpack

RUN npm install @types/mocha
# build necessary, even if no static files are needed,
# since it builds the server as well
RUN npm run build

# expose 5000 on container
EXPOSE 7000

# set app serving to permissive / assigned
ENV NUXT_HOST=0.0.0.0
# set app port
ENV NUXT_PORT=7000

# start the app
CMD [ "npm", "start" ]