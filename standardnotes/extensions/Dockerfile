FROM nginx:1.19.1 as base

RUN mkdir /usr/share/nginx/html/extensions
ADD *-extension.json /tmp/

# Folders extension
FROM base as folders
ENV FOLDERS_VERSION 1.3.3
RUN curl -Ls -o /tmp/folders-component.tgz https://github.com/standardnotes/folders-component/archive/$FOLDERS_VERSION.tar.gz && \
    mkdir /usr/share/nginx/html/extensions/folders && \
    tar -zxf /tmp/folders-component.tgz --strip-components 1 --directory /usr/share/nginx/html/extensions/folders/ && \
    rm /tmp/folders-component.tgz && \
    mv /tmp/folders-extension.json /usr/share/nginx/html/extensions/folders/extension.json && \
    curl -Ls -o /usr/share/nginx/html/extensions/folders/extension.zip https://github.com/standardnotes/folders/archive/1.3.3.zip

# Markdown Pro extension
FROM base as markdown-pro
ENV MARKDOWN_PRO_VERSION 1.3.8
RUN curl -Ls -o /tmp/markdown-pro.tgz https://github.com/standardnotes/markdown-pro/archive/$MARKDOWN_PRO_VERSION.tar.gz && \
    mkdir /usr/share/nginx/html/extensions/markdown-pro && \
    tar -zxf /tmp/markdown-pro.tgz --strip-components 1 --directory /usr/share/nginx/html/extensions/markdown-pro/ && \
    rm /tmp/markdown-pro.tgz && \
    mv /tmp/markdown-pro-extension.json /usr/share/nginx/html/extensions/markdown-pro/extension.json && \
    curl -Ls -o /usr/share/nginx/html/extensions/markdown-pro/extension.zip https://github.com/standardnotes/markdown-pro/archive/$MARKDOWN_PRO_VERSION.zip

# Simple Task Editor extension
FROM base as simple-task-editor
ENV SIMPLE_TASK_EDITOR_VERSION 1.3.5
RUN curl -Ls -o /tmp/simple-task-editor.tgz https://github.com/sn-extensions/simple-task-editor/archive/$SIMPLE_TASK_EDITOR_VERSION.tar.gz && \
    mkdir /usr/share/nginx/html/extensions/simple-task-editor && \
    tar -zxf /tmp/simple-task-editor.tgz --strip-components 2 --directory /usr/share/nginx/html/extensions/simple-task-editor/ simple-task-editor-$SIMPLE_TASK_EDITOR_VERSION/dist/ && \
    rm /tmp/simple-task-editor.tgz && \
    mv /tmp/simple-task-editor-extension.json /usr/share/nginx/html/extensions/simple-task-editor/extension.json && \
    curl -Ls -o /usr/share/nginx/html/extensions/simple-task-editor/extension.zip https://github.com/sn-extensions/simple-task-editor/archive/$SIMPLE_TASK_EDITOR_VERSION.zip

FROM base as output
COPY --from=folders /usr/share/nginx/html/extensions/folders /usr/share/nginx/html/extensions/folders
COPY --from=markdown-pro /usr/share/nginx/html/extensions/markdown-pro /usr/share/nginx/html/extensions/markdown-pro
COPY --from=simple-task-editor /usr/share/nginx/html/extensions/simple-task-editor /usr/share/nginx/html/extensions/simple-task-editor