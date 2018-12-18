FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

ARG HOME=/app
COPY . ${HOME}
RUN chown -R nobody:nogroup ${HOME}

ARG SHA
RUN echo ${SHA} > ${HOME}/sha.txt

EXPOSE 5537
USER nobody
CMD [ "./up.sh" ]
