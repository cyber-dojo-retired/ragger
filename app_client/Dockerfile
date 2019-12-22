FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

COPY --chown=nobody:nogroup . /app
EXPOSE 5538
USER nobody
CMD [ "/app/up.sh" ]
