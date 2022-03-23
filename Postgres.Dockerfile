FROM postgres:14.2-alpine
LABEL maintainer="Anderson Almeida GitHub <https://github.com/Anderson0xFF>"
LABEL info="My database service."
ENV POSTGRES_USER=alynx
ENV POSTGRES_PASSWORD=xqeWjWPCEGDLH5KuTQSFn
ENV POSTGRES_DB=task
EXPOSE 5432