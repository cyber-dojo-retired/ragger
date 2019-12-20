FROM cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

RUN gem install 'concurrent-ruby'

WORKDIR /app
COPY --chown=nobody:nogroup . .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG CYBER_DOJO_RAGGER_PORT
ENV PORT=${CYBER_DOJO_RAGGER_PORT}
EXPOSE ${CYBER_DOJO_RAGGER_PORT}

USER nobody
CMD [ "./up.sh" ]
