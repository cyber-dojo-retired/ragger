FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

COPY .  /app

CMD [ "./up.sh" ]
