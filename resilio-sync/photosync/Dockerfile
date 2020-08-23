FROM node:10.22-alpine

ENV NODE_ENV production

RUN apk add \
    exiftool \
    git

ADD package.json package-lock.json ./
RUN npm install

ADD index.js ./

ENV SOURCE_ROOT_PATH /source/
ENV DESTINATION_ROOT_PATH /destination/

CMD ["npm", "start"]
