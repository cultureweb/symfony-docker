#!/bin/bash

read -p "Enable (1) or disable (0) XDebug ?" XDEBUG_ENABLE

if [ $XDEBUG_ENABLE -eq 1 ]; then

  read -p "Remote machine ($xdebugRemoteMachine si vide) : " XDEBUG_REMOTE_MACHINE
  if [ -z $XDEBUG_REMOTE_MACHINE ]; then
    XDEBUG_REMOTE_MACHINE="$xdebugRemoteMachine"
  fi

  read -p "Remote port machine (90$userPrefixPort si vide) : " XDEBUG_REMOTE_PORT_MACHINE
  if [ -z $XDEBUG_REMOTE_PORT_MACHINE ]; then
    XDEBUG_REMOTE_PORT_MACHINE="90$userPrefixPort"
  fi

  echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
      && echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/xdebug.ini \
      && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
      && echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
      && echo "xdebug.remote_host=$XDEBUG_REMOTE_MACHINE" >> /usr/local/etc/php/conf.d/xdebug.ini \
      && echo "xdebug.remote_port=$XDEBUG_REMOTE_PORT_MACHINE" >> /usr/local/etc/php/conf.d/xdebug.ini \
      && echo "xdebug.remote_log='/tmp/xdebug.log'" >> /usr/local/etc/php/conf.d/xdebug.ini
else
  echo "" > /usr/local/etc/php/conf.d/xdebug.ini
fi

/etc/init.d/apache2 reload
