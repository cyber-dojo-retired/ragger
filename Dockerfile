FROM cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

RUN gem install 'concurrent-ruby'

WORKDIR /app
COPY --chown=nobody:nogroup . .

ARG SHA
ENV SHA=${SHA}

EXPOSE 5537
USER nobody
CMD [ "./up.sh" ]
