# ryeeaston.com ci dockerfile
# Author: rye
# go rams!
# h/t gh/beikeni

FROM python:3-slim
ARG RUNNERVER=""
ARG OWNER=""
ARG REPO=""
ARG REGTOKEN=""
ARG NICKNAME=""

# exit if args are still empty
RUN if [ -z "$RUNNERVER" ] || [ -z "$OWNER" ] || [ -z "$REPO" ] || [ -z "$REGTOKEN" ] || [ -z "$NICKNAME" ]; then echo "Arguments not set. Are you trying to build the Docker image without build.sh?"; exit 1; fi

# get current
# microsoft's openjdk prereqs & getting current again
# dependencies 
# make user
RUN apt update -y && apt upgrade -y && \
	apt install -y wget lsb-release && \
	wget https://packages.microsoft.com/config/debian/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
	dpkg -i packages-microsoft-prod.deb && \
	apt update -y && \
	apt install -y curl jq g++ make libssl-dev libffi-dev && \
	apt install -y bash msopenjdk-21 tmux maven cron && \
	adduser ryebot

# establish structure
RUN mkdir /home/ryebot/runner && \
	mkdir /home/ryebot/server

# get runner
RUN cd /home/ryebot/runner && \
	curl -O -L "https://github.com/actions/runner/releases/download/v$RUNNERVER/actions-runner-linux-arm64-$RUNNERVER.tar.gz" && \
	tar xzf "./actions-runner-linux-arm64-$RUNNERVER.tar.gz"

# set up runner, give it all to ryebot
RUN home/ryebot/runner/bin/installdependencies.sh && chown -R ryebot ~ryebot

# done with root
USER ryebot

# init runner with repo, token, and name
RUN /home/ryebot/runner/config.sh --unattended --url "https://github.com/$OWNER/$REPO" --token "$REGTOKEN" --replace --name "$REPO.$NICKNAME"

SHELL ["/bin/bash"]
CMD ["tail", "-f", "/dev/null"]