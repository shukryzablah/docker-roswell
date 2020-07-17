# Get Arch Linux and update all packages.
FROM archlinux AS builder
RUN pacman -Syu --noconfirm

# Install dependencies to make packages.
RUN pacman -S base-devel --noconfirm --needed

# Create a user that can use sudo makepkg and pacman without password.
ARG USERNAME=shukry
RUN useradd -m ${USERNAME} && \
    echo "${USERNAME} ALL= NOPASSWD: /usr/bin/makepkg,/usr/bin/pacman -U" >> /etc/sudoers.d/{$USERNAME}

# Install Roswell from AUR
ARG USERNAME=shukry
USER ${USERNAME}
RUN mkdir -p "/home/${USERNAME}/builds" && \
    cd "/home/${USERNAME}/builds" && \
    curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/roswell.tar.gz -o roswell.tar.gz && \
    tar -xvf roswell.tar.gz && \
    cd roswell && \
    makepkg -src --noconfirm

# Get Arch Linux and update all packages.
FROM archlinux
RUN pacman -Syu --noconfirm
RUN pacman -S base-devel --noconfirm --needed

# Retrieve built package and install with pacman.
ARG USERNAME=shukry
ARG PKGVERSION="20.06.14.107"
COPY --from=builder /home/${USERNAME}/builds/roswell/roswell-${PKGVERSION}-1-x86_64.pkg.tar.zst .
RUN pacman -U roswell-${PKGVERSION}-1-x86_64.pkg.tar.zst --noconfirm

# Run the default Roswell REPL.
ENV PATH /root/.roswell/bin:${PATH}
ENTRYPOINT ["ros"]
CMD ["run"]
