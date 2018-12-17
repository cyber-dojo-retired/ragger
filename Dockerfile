FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

COPY .  /app
EXPOSE 5537
CMD [ "./up.sh" ]
