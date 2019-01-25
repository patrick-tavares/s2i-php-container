config_php_fpm_conf() {
  sed -i "s%^error_log = ${PHP_VAR_PATH}/log/php-fpm/error.log%error_log = /proc/self/fd/2%" ${PHP_SYSCONF_PATH}/${PHP_FPM_CONF_FILE}
  sed -i "s/^daemonize = yes/daemonize = no/" ${PHP_SYSCONF_PATH}/${PHP_FPM_CONF_FILE}
  sed -i "s/^;systemd_interval = 10/systemd_interval = 0/" ${PHP_SYSCONF_PATH}/${PHP_FPM_CONF_FILE}
  sed -i "s%^;access.log = log/\$pool.access.log%access.log = /proc/self/fd/2%" ${PHP_FPM_CONFIGURATION_PATH}/${PHP_FPM_WWW_POOL_CONF_FILE}
  sed -i "s%^slowlog = ${PHP_VAR_PATH}/log/php-fpm/www-slow.log%slowlog = /proc/self/fd/2%" ${PHP_FPM_CONFIGURATION_PATH}/${PHP_FPM_WWW_POOL_CONF_FILE}
  sed -i 's#^;access.format = .*#access.format = "[%t] %m %{REQUEST_SCHEME}e://%{HTTP_HOST}e%{REQUEST_URI}e %f pid:%p took:%ds mem:%{mega}Mmb cpu:%C%% status:%s {%{REMOTE_ADDR}e|%{HTTP_USER_AGENT}e}"#' ${PHP_FPM_CONFIGURATION_PATH}/${PHP_FPM_WWW_POOL_CONF_FILE}
  sed -i "s/^user = apache/;user = apache/" ${PHP_FPM_CONFIGURATION_PATH}/${PHP_FPM_WWW_POOL_CONF_FILE}
  sed -i "s/^group = apache/;group = apache/" ${PHP_FPM_CONFIGURATION_PATH}/${PHP_FPM_WWW_POOL_CONF_FILE}
  sed -i "s/^listen = .*/listen = 9000/" ${PHP_FPM_CONFIGURATION_PATH}/${PHP_FPM_WWW_POOL_CONF_FILE}
  sed -i "s/^listen.allowed_clients/;listen.allowed_clients/" ${PHP_FPM_CONFIGURATION_PATH}/${PHP_FPM_WWW_POOL_CONF_FILE}
  sed -i "s%^;ping.path = /ping%ping.path = /ping%" ${PHP_FPM_CONFIGURATION_PATH}/${PHP_FPM_WWW_POOL_CONF_FILE}
  sed -i "s%^;catch_workers_output = yes%catch_workers_output = yes%" ${PHP_FPM_CONFIGURATION_PATH}/${PHP_FPM_WWW_POOL_CONF_FILE}
  sed -i "s%^php_value\[session.save_path\].*= ${PHP_VAR_PATH}/lib/php/session%php_admin_value\[session.save_path\] = /tmp/session%" ${PHP_FPM_CONFIGURATION_PATH}/${PHP_FPM_WWW_POOL_CONF_FILE}
  sed -i "s%^;php_value\[soap.wsdl_cache_dir\].*= ${PHP_VAR_PATH}/lib/php/wsdlcache%php_admin_value\[soap.wsdl_cache_dir\] = /tmp/wsdlcache%" ${PHP_FPM_CONFIGURATION_PATH}/${PHP_FPM_WWW_POOL_CONF_FILE}
  sed -i "s%^;php_value\[opcache.file_cache\].*= ${PHP_VAR_PATH}/lib/php/opcache%php_admin_value\[opcache.file_cache\] = /tmp/opcache%" ${PHP_FPM_CONFIGURATION_PATH}/${PHP_FPM_WWW_POOL_CONF_FILE}
  sed -i "s%^php_admin_value\[error_log\].*= ${PHP_VAR_PATH}/log/php-fpm/www-error.log%php_admin_value\[error_log\] = /proc/self/fd/2%" ${PHP_FPM_CONFIGURATION_PATH}/${PHP_FPM_WWW_POOL_CONF_FILE}
  sed -i "s%^;php_flag\[display_errors\].*off%php_admin_value\[display_errors\] = off%" ${PHP_FPM_CONFIGURATION_PATH}/${PHP_FPM_WWW_POOL_CONF_FILE}
  sed -i "s%^;pm.status_path = /status%pm.status_path = /status%" ${PHP_FPM_CONFIGURATION_PATH}/${PHP_FPM_WWW_POOL_CONF_FILE}
}

config_general() {
  config_php_fpm_conf
}

function log_info {
  echo "---> `date +%T`     $@"
}

# get_matched_files finds file for image extending
function get_matched_files() {
  local custom_dir default_dir
  custom_dir="$1"
  default_dir="$2"
  files_matched="$3"
  find "$default_dir" -maxdepth 1 -type f -name "$files_matched" -printf "%f\n"
  [ -d "$custom_dir" ] && find "$custom_dir" -maxdepth 1 -type f -name "$files_matched" -printf "%f\n"
}

# process_extending_files process extending files in $1 and $2 directories
# - source all *.sh files
#   (if there are files with same name source only file from $1)
function process_extending_files() {
  local custom_dir default_dir
  custom_dir=$1
  default_dir=$2

  while read filename ; do
    echo "=> sourcing $filename ..."
    # Custom file is prefered
    if [ -f $custom_dir/$filename ]; then
      source $custom_dir/$filename
    elif [ -f $default_dir/$filename ]; then
      source $default_dir/$filename
    fi
  done <<<"$(get_matched_files "$custom_dir" "$default_dir" '*.sh' | sort -u)"
}

# process extending config files in $1 and $2 directories
# - expand variables in *.conf and copy the files into /opt/app-root/etc/httpd.d directory
#   (if there are files with same name source only file from $1)
function process_extending_config_files() {
  local custom_dir default_dir
  custom_dir=$1
  default_dir=$2

  while read filename ; do
    echo "=> sourcing $filename ..."
    # Custom file is prefered
    if [ -f $custom_dir/$filename ]; then
       envsubst < $custom_dir/$filename > ${HTTPD_CONFIGURATION_PATH}/$filename
    elif [ -f $default_dir/$filename ]; then
       envsubst < $default_dir/$filename > ${HTTPD_CONFIGURATION_PATH}/$filename
    fi
  done <<<"$(get_matched_files "$custom_dir" "$default_dir" '*.conf' | sort -u)"
}
