FROM archlinux

RUN groupadd --gid 1010 archuser && \
    useradd --no-log-init --create-home -g archuser --uid 1010 archuser

ADD test.sh /root/test.sh
