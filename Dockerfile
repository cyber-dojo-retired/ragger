FROM cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

RUN gem install 'concurrent-ruby'

WORKDIR /app
COPY --chown=nobody:nogroup . .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

EXPOSE 5537
USER nobody
CMD [ "./up.sh" ]
