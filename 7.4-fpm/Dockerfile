FROM registry.access.redhat.com/ubi8/s2i-base

# Description
# This image provides a standalone PHP 7.4 + PHP-FPM environment for running PHP applications
# and providing the resulting output for consumption by a separate Apache or Nginx (or other
# fast-cgi capable web server) container.

# Exposed ports:
# * 9000 - for php-fpm

EXPOSE 9000

ENV PHP_VERSION=7.4 \
    PHP_VER_SHORT=74 \
    NAME=php

ENV SUMMARY="Platform for building and running PHP $PHP_VERSION applications" \
    DESCRIPTION="PHP $PHP_VERSION, running inside PHP-FPM, available as a container, \
is a base platform for building and running various PHP $PHP_VERSION applications and frameworks. \
PHP is an HTML-embedded scripting language. PHP attempts to make it easy for developers \
to write dynamically generated web pages. PHP also offers built-in database integration \
for several commercial and non-commercial database management systems, so writing \
a database-enabled webpage with PHP is fairly simple. The most common use of PHP coding \
is probably as a replacement for CGI scripts."

LABEL summary="${SUMMARY}" \
      description="${DESCRIPTION}" \
      io.k8s.description="${DESCRIPTION}" \
      io.k8s.display-name="PHP-FPM with PHP ${PHP_VERSION}" \
      io.openshift.expose-services="9000:http" \
      io.openshift.tags="builder,${NAME},${NAME}${PHP_VER_SHORT},rh-${NAME}${PHP_VER_SHORT},${name}-fpm" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i" \
      io.s2i.scripts-url="image:///usr/libexec/s2i" \
      name="ubi8/${NAME}-${PHP_VER_SHORT}-fpm-ubi8" \
      com.redhat.component="rh-${NAME}${PHP_VER_SHORT}-fpm-container" \
      version="${PHP_VERSION}" \
      help="For more information visit https://github.com/sclorg/s2i-${NAME}-container" \
      usage="s2i build https://github.com/sclorg/s2i-php-container.git --context-dir=${PHP_VERSION}-fpm/test/test-app ubi8/${NAME}-${PHP_VER_SHORT}-fpm-ubi8 sample-server" \
      maintainer="SoftwareCollections.org <sclorg@redhat.com>"

# Install PHP-FPM and PHP
RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm https://rpms.remirepo.net/enterprise/remi-release-8.rpm && \
    yum module install -y php:remi-$PHP_VERSION && \
    INSTALL_PKGS="php \
                  php-mysqlnd \
                  php-opcache php-soap \
                  php-pecl-gmagick" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all

ENV APP_DATA=${APP_ROOT}/src \
    PHP_CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/php/ \
    PHP_DEFAULT_INCLUDE_PATH=/usr/share/pear \
    PHP_SYSCONF_PATH=/etc \
    PHP_VAR_PATH=/var

ENV PHP_FPM_CONFIGURATION_PATH=${PHP_SYSCONF_PATH}/php-fpm.d \
    PHP_FPM_RUN=/run/php-fpm \
    PHP_FPM_CONF_FILE=php-fpm.conf \
    PHP_FPM_WWW_POOL_CONF_FILE=www.conf

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Copy extra files to the image.
COPY ./root/ /

# Reset permissions of filesystem to default values
RUN /usr/libexec/container-setup && rpm-file-permissions

USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage
