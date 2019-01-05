FROM centos/s2i-base-centos7

# Description
# This image provides a standalone PHP 7.1 + PHP-FPM environment for running PHP applications
# and providing the resulting output for consumption by a separate Apache or Nginx (or other
# fast-cgi capable web server) container.

# Exposed ports:
# * 9000 - for php-fpm

EXPOSE 9000

ENV PHP_VERSION=7.1 \
    PHP_VER_SHORT=71 \
    NAME=php \
    PATH=$PATH:/opt/rh/rh-php71/root/usr/bin

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
      name="centos/${NAME}-${PHP_VER_SHORT}-fpm-centos7" \
      com.redhat.component="rh-${NAME}${PHP_VER_SHORT}-fpm-container" \
      version="${PHP_VERSION}" \
      help="For more information visit https://github.com/sclorg/s2i-${NAME}-container" \
      usage="s2i build https://github.com/sclorg/s2i-php-container.git --context-dir=${PHP_VERSION}_fpm/test/test-app centos/${NAME}-${PHP_VER_SHORT}-fpm-centos7 sample-server" \
      maintainer="SoftwareCollections.org <sclorg@redhat.com>"

# Install PHP-FPM and PHP
RUN INSTALL_PKGS="rh-php${PHP_VER_SHORT} rh-php${PHP_VER_SHORT}-php-fpm \
                  rh-php${PHP_VER_SHORT}-php-mysqlnd rh-php${PHP_VER_SHORT}-php-pgsql \
                  rh-php${PHP_VER_SHORT}-php-bcmath rh-php${PHP_VER_SHORT}-php-gd rh-php${PHP_VER_SHORT}-php-intl \
                  rh-php${PHP_VER_SHORT}-php-ldap rh-php${PHP_VER_SHORT}-php-mbstring rh-php${PHP_VER_SHORT}-php-pdo \
                  rh-php${PHP_VER_SHORT}-php-process rh-php${PHP_VER_SHORT}-php-soap rh-php${PHP_VER_SHORT}-php-opcache \
                  rh-php${PHP_VER_SHORT}-php-xml rh-php${PHP_VER_SHORT}-php-gmp rh-php${PHP_VER_SHORT}-php-pecl-apcu" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS --nogpgcheck && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y

ENV PHP_DEFAULT_BASE_PATH=/opt/rh/rh-php${PHP_VER_SHORT}

ENV APP_DATA=${APP_ROOT}/src \
    PHP_CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/php/ \
    PHP_DEFAULT_INCLUDE_PATH=${PHP_DEFAULT_BASE_PATH}/root/usr/share/pear \
    PHP_SYSCONF_PATH=/etc${PHP_DEFAULT_BASE_PATH} \
    PHP_VAR_PATH=/var${PHP_DEFAULT_BASE_PATH} \
    SCL_ENABLED=rh-php${PHP_VER_SHORT}

ENV PHP_FPM_CONFIGURATION_PATH=${PHP_SYSCONF_PATH}/php-fpm.d \
    PHP_FPM_RUN=${PHP_VAR_PATH}/run/php-fpm \
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
