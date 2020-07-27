FROM nginx:1.19.1

ARG VERSION
ENV VERSION ${VERSION}

ADD https://github.com/standardnotes/folders-component/archive/$VERSION.tar.gz /tmp/folders-component-$VERSION.tgz

RUN tar -zxf /tmp/folders-component-$VERSION.tgz --strip-components 1 --directory /usr/share/nginx/html/ && \
    rm /tmp/folders-component-$VERSION.tgz

ADD extension.json /usr/share/nginx/html/
