#!/bin/bash
set -e

# Handle PUID/PGID for Unraid compatibility
PUID=${PUID:-2000}
PGID=${PGID:-2000}

# Create group if it doesn't exist
if ! getent group metabase >/dev/null; then
    groupadd -g "$PGID" metabase
else
    # Update existing group GID if needed
    current_gid=$(getent group metabase | cut -d: -f3)
    if [ "$current_gid" != "$PGID" ]; then
        groupmod -g "$PGID" metabase
    fi
fi

# Create or update user
if ! getent passwd metabase >/dev/null; then
    useradd -u "$PUID" -g "$PGID" -d /home/metabase -s /bin/bash metabase
else
    # Update existing user UID/GID if needed
    current_uid=$(getent passwd metabase | cut -d: -f3)
    if [ "$current_uid" != "$PUID" ]; then
        usermod -u "$PUID" -g "$PGID" metabase
    fi
fi

# Ensure proper ownership of important directories
chown -R metabase:metabase /home /plugins /data

# Handle timezone
if [ -n "$TZ" ]; then
    export JAVA_TIMEZONE="$TZ"
fi

# Switch to metabase user and run the application
exec gosu metabase java -jar /home/metabase.jar "$@"
