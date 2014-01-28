# Dockerfile for an email server with postfix and dovecot served by mysql
# forked from Nicolas Cadou <ncadou@cadou.ca>

FROM dsissitka/ubunturaring
MAINTAINER Simon Herkenhoff <s.herkenhoff@netrocks.info>

ENV DEBIAN_FRONTEND noninteractive

# upgrade packages and install ansible
RUN echo 'deb http://archive.ubuntu.com/ubuntu raring main universe' > /etc/apt/sources.list \
		&& apt-get update && apt-get upgrade -y && apt-get clean \
		&& apt-get install -y --no-install-recommends python-apt \
		python-jinja2 python-paramiko python-pip python-yaml \
		&& apt-get clean && pip install ansible

# generates a random password via startup script
ENV RANDOMIZE_PASSWORD 1

# hostname used as hostname and mailname
ENV HOSTNAME mail.localhost

# generic mail settings
ENV VMAIL_USER vmail
ENV VMAIL_UID 150
ENV VMAIL_GROUP mail
ENV VMAIL_GID 8
ENV VMAIL_DIR /var/vmail

# upstart doesn't work inside a docker container, so we deactivate it to work
# around post-install scripts that want to talk to it and fail when they can't.
RUN dpkg-divert --local --rename --add /sbin/initctl \
		&& ln -s /bin/true /sbin/initctl

# install and setup the mail server
RUN bash -c 'debconf-set-selections <<< "postfix postfix/mailname string $HOSTNAME"'
RUN apt-get install -y --no-install-recommends amavis bcrypt bsd-mailx clamav \
		clamav-daemon dovecot-core dovecot-imapd dovecot-managesieved \
		dovecot-pop3d dovecot-sieve dovecot-mysql git rsyslog logrotate \
		openssh-server postfix-mysql postgrey procmail spamassassin pwgen \
		ssl-cert && apt-get clean

# update clamav and remove postgrey.pid
RUN freshclam && rm /var/run/postgrey.pid

# inject ansible files
ADD ansible /.ansible

# run ansible base setup script
RUN /.ansible/setup-base.sh

# expose ports used for mail and ssh
EXPOSE 22 25 110 143 465 993 995

# this let's us use a permanent mail directory
VOLUME ["/var/vmail"]

# set start command
CMD ["/start"]
