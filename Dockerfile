FROM ruby:2.6.3

ENV APP_HOME=/home/toolbox
ENV HEY_RELEASE_URL="https://storage.googleapis.com/jblabs/dist/hey_linux_v0.1.2"
ENV DEBIAN_FRONTEND nointeractive

# Enable bash completion and improve readability
RUN chsh -s /bin/bash && echo 'source $APP_HOME/.bashrc' >> ~/.bashrc

# Prepare apt and make sure the system's up-to-date
RUN apt-get update && apt-get install -y apt-utils && apt-get upgrade -y

# Install tools for debug and development
RUN apt-get install -y --no-install-recommends \
      git less curl wget htop man vim nuttcp bash-completion liquidprompt \
      nmap siege strace netcat tcpdump iperf3 nload apache2-utils dnsutils \
      dnstracer darkstat dstat mariadb-client-10.1 apt-utils

# Install hey
RUN curl "${HEY_RELEASE_URL}" -o /usr/bin/hey

WORKDIR $APP_HOME

# Install dependencies defined in Gemfile.
COPY Gemfile Gemfile.lock $APP_HOME/
RUN mkdir -p /opt/vendor/bundle \
 && bundle install --path /opt/vendor/bundle

# Copy application sources.
COPY . $APP_HOME

CMD ["/bin/bash", "-l"]
