FROM tmaczukin/debian
MAINTAINER Tomasz Maczukin "tomasz@maczukin.pl"

# Prepare entrypoint
RUN mkdir /app
WORKDIR /app
EXPOSE 80

ENTRYPOINT ["/usr/local/sbin/init"]
CMD ["start"]

# Install packages
RUN apt-get update; \
    apt-get install -y git-core locales tzdata supervisor build-essential \
                       zlib1g-dev libssl-dev libreadline-dev libyaml-dev \
                       libxml2-dev libxslt-dev libffi-dev; \
    apt-get clean

# Set locales and timezone
ENV TZ Europe/Warsaw
ENV LANG pl_PL.UTF-8
ENV LC_ALL pl_PL.UTF-8
ENV LANGUAGE pl_PL.UTF-8
RUN echo $TZ > /etc/timezone; \
    sed -i "s/^# pl_PL.UTF-8/pl_PL.UTF-8/" /etc/locale.gen; \
    locale-gen; \
    dpkg-reconfigure locales; \
    dpkg-reconfigure tzdata

# Install rbenv
ENV CONFIGURE_OPTS --disable-install-doc
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv; \
    mkdir -p /usr/local/rbenv/plugins; \
    git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build; \
    cd /usr/local/rbenv/plugins/ruby-build; \
    ./install.sh

RUN echo "export RBENV_ROOT=\"/usr/local/rbenv\"" >> /etc/rbenvrc; \
    echo "export PATH=\"\$RBENV_ROOT/bin:\$PATH\"" >> /etc/rbenvrc; \
    echo "eval \"\$(rbenv init -)\"" >> /etc/rbenvrc; \
    echo "gem: --no-rdoc --no-ri" >> /etc/skel/.gemrc; \
    echo "gem: --no-rdoc --no-ri" >> /root/.gemrc; \
    echo "source /etc/rbenvrc" >> /etc/skel/.bashrc ;\
    echo "source /etc/rbenvrc" >> /root/.bashrc

# Install ruby
RUN bash -l -c "source /etc/rbenvrc && rbenv install 2.2.0 && rbenv global 2.2.0 && gem install bundler"; \
    addgroup rbenv; \
    chown :rbenv -R /usr/local/rbenv; \
    chmod g+w -R /usr/local/rbenv

# Install geminabox
COPY app/* /app/
RUN bash -l -c "source /etc/rbenvrc && bundle install"

# Install entrypoint
COPY assets/supervisor/* /etc/supervisor/conf.d/
COPY assets/init /usr/local/sbin/init
RUN chmod 700 /usr/local/sbin/init; \
    chown root:root /usr/local/sbin/init
