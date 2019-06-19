FROM ruby:2.6.2

ENV APP_HOME=/home/toolbox
ENV HEY_RELEASE_URL="https://storage.googleapis.com/jblabs/dist/hey_linux_v0.1.2"

# Install tools for debug and development
RUN apt update && apt install -y \
      git less curl wget htop man vim nuttcp bash-completions liquidprompt nmap \
      siege strace netcat tcpdump iperf3 wireshark nload apache2-utils dnsutils \
      dnstracer darkstat dstat mariadb-client-10.1

# Enable bash completion and improve readability
RUN chsh -s /bin/bash \
    && liquidprompt_activate \
    && echo 'source /etc/profile.d/bash-completion.bash' >> ~/.bash_profile

# Install hey
RUN curl "${HEY_RELEASE_URL}" -o /usr/bin/hey

WORKDIR $APP_HOME

# Install dependencies defined in Gemfile.
COPY Gemfile Gemfile.lock $APP_HOME/
RUN mkdir -p /opt/vendor/bundle \
 && bundle install --path /opt/vendor/bundle

# Copy application sources.
COPY . $APP_HOME
