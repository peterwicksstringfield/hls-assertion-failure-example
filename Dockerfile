# Use this command:
# docker build -t testbuild .

FROM debian:buster

RUN apt-get update && apt-get install -y \
    build-essential \
    binutils \
    curl \
    git

ENV USER builder

RUN useradd -ms /bin/bash $USER

USER $USER
ENV HOME /home/$USER
WORKDIR $HOME
RUN mkdir -p project
WORKDIR $HOME/project/

RUN curl --proto '=https' --tlsv1.2 -sSf https://downloads.haskell.org/~ghcup/x86_64-linux-ghcup > ghcup

RUN chmod +x ghcup

ENV PATH="/home/builder/.ghcup/bin:$PATH"

RUN ./ghcup install ghc 8.10.2
RUN ./ghcup install stack
RUN ./ghcup install hls

COPY --chown=$USER app/ app/
COPY --chown=$USER src/ src/
COPY --chown=$USER stack.yaml stack.yaml
COPY --chown=$USER stack.yaml.lock stack.yaml.lock
COPY --chown=$USER package.yaml package.yaml

RUN stack build

RUN haskell-language-server-wrapper

ENTRYPOINT ["/bin/bash"]