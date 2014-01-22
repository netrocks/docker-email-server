Dockerfile for building an email server with MySQL connector and Mailadmin
==========================================================================

Based on https://github.com/ncadou/docker-email-server
Based on https://www.exratione.com/2012/05/a-mailserver-on-ubuntu-1204-postfix-dovecot-mysql/

This Dockerfile with ansible integration will install and configure the
following packages and their dependencies:

	- postfix
	- dovecot-mysql
	- nginx
	- php5
	- vimbadmin
	- spamassassin
	- clamav
	- postgrey

Mailserver hostname and MySQL connection parameters have to be set in
ansible/vars/defaults.yml.
