#!/bin/bash
set -e

# Handle PUID/PGID for Unraid compatibility
PUID=${PUID:-2000}
PGID=${PGID:-2000}

# Find or create group for the desired GID
TARGET_GROUP=$(getent group "$PGID" | cut -d: -f1 || echo "")
if [ -z "$TARGET_GROUP" ]; then
    # GID doesn't exist, create metabase group
    groupadd -g "$PGID" metabase
    TARGET_GROUP="metabase"
else
    # GID already exists, use that group
    echo "Using existing group '$TARGET_GROUP' with GID $PGID"
fi

# Create or update user
if ! getent passwd metabase >/dev/null; then
    useradd -u "$PUID" -g "$PGID" -d /home/metabase -s /bin/bash metabase
else
    # Update existing user UID/GID if needed
    current_uid=$(getent passwd metabase | cut -d: -f3)
    current_gid=$(getent passwd metabase | cut -d: -f4)
    if [ "$current_uid" != "$PUID" ] || [ "$current_gid" != "$PGID" ]; then
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
