FROM openjdk:19-jdk-slim

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

# Set proper permissions
RUN chmod 644 /home/metabase.jar /plugins/duckdb.metabase-driver.jar

# Create user and set ownership
RUN groupadd -r metabase && useradd -r -g metabase metabase
RUN chown -R metabase:metabase /home /plugins /data

# Switch to non-root user
USER metabase

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/api/health || exit 1

# Default command
CMD ["java", "-jar", "/home/metabase.jar"]
