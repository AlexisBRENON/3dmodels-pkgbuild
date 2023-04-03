FROM --platform=linux/amd64 archlinux

RUN pacman -Sy --noconfirm \
    base-devel \
    git \
    namcap \
    openssh && rm -fr /var/cache/pacman

RUN useradd -m arch
USER arch
RUN mkdir /home/arch/.ssh
RUN touch /home/arch/.ssh/known_hosts

VOLUME /home/arch/.ssh/id_rsa
