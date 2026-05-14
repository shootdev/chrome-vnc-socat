# https://stackoverflow.com/questions/70955307/how-to-install-google-chrome-in-a-docker-container

FROM ubuntu:22.04

RUN apt-get update; apt-get clean

# Install wget.
RUN apt-get install -y wget

RUN apt-get install -y gnupg

# Set the Chrome repo.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

# Install Chrome.
RUN apt-get update && apt-get -y install google-chrome-stable