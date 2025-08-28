FROM openjdk:19-jdk-slim

# Install gosu for user switching
RUN apt-get update && apt-get install -y gosu curl && rm -rf /var/lib/apt/lists/*

# Set up environment
ENV MB_PLUGINS_DIR=/plugins/
ENV JAVA_TIMEZONE=UTC

# Create necessary directories
RUN mkdir -p /plugins /data

# Download Metabase and DuckDB driver
# renovate: datasource=github-releases depName=metabase/metabase
ADD https://downloads.metabase.com/v0.56.3/metabase.jar /home/metabase.jar
# renovate: datasource=github-releases depName=MotherDuck-Open-Source/metabase_duckdb_driver
ADD https://github.com/MotherDuck-Open-Source/metabase_duckdb_driver/releases/download/0.4.1/duckdb.metabase-driver.jar /plugins/duckdb.metabase-driver.jar

# Add entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set proper permissions
RUN chmod 644 /home/metabase.jar /plugins/duckdb.metabase-driver.jar

# Create initial user and group (will be updated by entrypoint if PUID/PGID provided)
RUN groupadd -g 2000 metabase && useradd -u 2000 -g 2000 -d /home/metabase -s /bin/bash metabase
RUN chown -R metabase:metabase /home /plugins /data

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/api/health || exit 1

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Default command
CMD []
