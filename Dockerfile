# Use this command:
# docker build -t testbuild .

FROM debian:buster

RUN apt-get update && apt-get install -y \
    build-essential \
    binutils \
    curl \
    libffi-dev \
    libffi6 \
    libgmp-dev \
    libgmp10 \
    libncurses-dev \
    libncurses5

ENV USER builder
RUN useradd -ms /bin/bash $USER
USER $USER
ENV HOME /home/$USER
WORKDIR $HOME

RUN mkdir -p .ghcup/bin
RUN curl --proto '=https' --tlsv1.2 -sSf https://downloads.haskell.org/~ghcup/x86_64-linux-ghcup > .ghcup/bin/ghcup
RUN chmod +x .ghcup/bin/ghcup
ENV PATH="/home/builder/.ghcup/bin:$PATH"

RUN ghcup upgrade
RUN ghcup install ghc 8.10.2
RUN ghcup install hls
RUN ghcup set ghc 8.10.2
RUN ghcup install cabal
RUN cabal update

RUN mkdir -p project
WORKDIR $HOME/project/

RUN cabal v2-install --lib ghc

COPY --chown=$USER app/ app/
COPY --chown=$USER src/ src/
COPY --chown=$USER component.cabal component.cabal
COPY --chown=$USER hie.yaml hie.yaml

RUN cabal v2-build

RUN haskell-language-server-wrapper

ENTRYPOINT ["/bin/bash"]