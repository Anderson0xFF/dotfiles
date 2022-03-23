FROM archlinux
LABEL maintainer="Anderson Almeida GitHub <https://github.com/Anderson0xFF>"
RUN yes | pacman -Syyu
RUN yes | pacman -S base base-devel
RUN useradd -m -g users -G wheel alynx
WORKDIR /home/alynx/
USER alynx
