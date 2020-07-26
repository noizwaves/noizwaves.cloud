FROM nginx:1.19.1

ARG VERSION
ENV VERSION ${VERSION}

ADD https://github.com/standardnotes/markdown-pro/archive/$VERSION.tar.gz /tmp/markdown-pro-$VERSION.tgz

RUN tar -zxf /tmp/markdown-pro-$VERSION.tgz --strip-components 1 --directory /usr/share/nginx/html/ && \
    rm /tmp/markdown-pro-$VERSION.tgz

ADD extension.json /usr/share/nginx/html/
