# ryeeaston.com cd dockerfile
# Author: rye
# go rams!

FROM python:3-slim

RUN apt update -y && apt upgrade -y && \
	apt install -y wget lsb-release && \
	wget https://packages.microsoft.com/config/debian/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
	dpkg -i packages-microsoft-prod.deb && \
	apt update -y && \
	apt install -y bash msopenjdk-21 tmux maven cron && \
	adduser prod

RUN mkdir /home/prod/bin

RUN chown -R prod ~prod

USER prod

SHELL ["/bin/bash"]
CMD ["tail", "-f", "/dev/null"]