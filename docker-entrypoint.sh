#!/bin/bash

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- haproxy "$@"
fi

if [ "$1" = 'haproxy' ]; then
	# if the user wants "haproxy", let's use "haproxy-systemd-wrapper" instead so we can have proper reloadability implemented by upstream
	shift # "haproxy"
	set -- "$(which haproxy-systemd-wrapper)" -p /run/haproxy.pid "$@"
fi

# enable job control, start processes
set -m

# Set 'TRACE=y' environment variable to see detailed output for debugging
[ "$TRACE" = "y" ] && set -x

# Run rsyslogd if enabled
RSYSLOG_PID=0
if [ "$RSYSLOG" != "n" ]; then
	rsyslogd -n -f /etc/rsyslogd.conf &
	RSYSLOGD_PID=$!
fi

# Run HAProxy (haproxy-systemd-wrapper) and wait for exit
"$@" &
WRAPPER_PID=$!

# Trap Shutdown
function shutdown () {
	echo $PREFIX: Shutting down...
	kill -TERM $WRAPPER_PID
}
trap shutdown TERM INT

# Trap Reload (HUP)
function reload () {
	if haproxy -c -f ${TEMPLATE%.tpl} >/dev/null; then
		echo $PREFIX: Reloading config...
		kill -HUP $WRAPPER_PID
	else
		echo $PREFIX: Config test failed, will not reload haproxy.
	fi
}
trap reload HUP

wait $WRAPPER_PID
RC=$?

[ "$RSYSLOG_PID" -ne 0 ] && kill $RSYSLOG_PID
exit $RC
