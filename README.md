# Metabase with DuckDB Support

A custom Docker image for Metabase with DuckDB driver support, allowing you to use DuckDB as a data source in Metabase.

## Features

- **Metabase v0.56.3** - Latest stable version
- **DuckDB Driver v0.2.12** - MotherDuck's DuckDB driver for Metabase
- **Security Hardened** - Runs as non-root user
- **Persistent Data** - DuckDB files stored in `/data` directory
- **Health Checks** - Built-in container health monitoring

## Quick Start

### Using Docker Compose (Recommended)

```bash
git clone <your-repo-url>
cd metabaseDuck
docker-compose up -d
```

Access Metabase at http://localhost:3000

### Using Docker

```bash
docker build -t metabase-duckdb .
docker run -d \
  -p 3000:3000 \
  -v $(pwd)/data:/data \
  --name metabase-duckdb \
  metabase-duckdb
```

### Unraid Compatibility

This image is fully compatible with Unraid and supports `PUID`/`PGID` environment variables for proper file permissions:

```bash
docker run -d \
  --name='metabase' \
  -e TZ="America/Los_Angeles" \
  -e 'MB_DB_TYPE'='postgres' \
  -e 'MB_DB_HOST'='your-db-host' \
  -e 'MB_DB_PORT'='5432' \
  -e 'MB_DB_DBNAME'='metabase' \
  -e 'MB_DB_USER'='your-db-user' \
  -e 'MB_DB_PASS'='your-db-password' \
  -e 'PUID'='99' \
  -e 'PGID'='100' \
  -p '3000:3000/tcp' \
  -v '/mnt/user/appdata/metabase/plugins':'/plugins':'rw' \
  -v '/mnt/user/appdata/metabase/data':'/data':'rw' \
  your-dockerhub-username/metabase-duckdb
```

## Configuration

### Environment Variables

- `MB_PLUGINS_DIR`: Plugin directory (default: `/home/plugins/`)
- `MB_DB_TYPE`: Metabase database type (default: `h2`)
- `MB_DB_FILE`: Metabase database file location
- `JAVA_TIMEZONE`: Java timezone setting

### DuckDB Connection

When setting up a DuckDB connection in Metabase:

1. Go to Admin → Databases → Add database
2. Select "DuckDB" from the database type dropdown
3. Configure your DuckDB database path (store files in `/data/` for persistence)

### Data Persistence

The `/data` directory is mounted as a volume to persist:

- DuckDB database files
- Metabase application database
- Any uploaded data files

## Development

### Building the Image

```bash
docker build -t metabase-duckdb .
```

### Running Locally

```bash
docker-compose up --build
```

## Deployment

The repository includes GitHub Actions workflow for automatic Docker image builds and pushes to Docker Hub.

### Required Secrets

Set these in your GitHub repository secrets:

- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub password/token

## Automated Updates

This repository uses [Renovate](https://renovatebot.com/) to automatically keep dependencies up to date:

- **Metabase versions** are monitored from the official GitHub releases
- **DuckDB driver versions** are monitored from MotherDuck's GitHub releases
- Updates are scheduled weekly on Mondays before 6 AM UTC
- All updates create pull requests for review before merging

To enable Renovate for your fork, install the [Renovate GitHub App](https://github.com/apps/renovate) on your repository.

## Versions

- **Metabase**: v0.56.3 (auto-updated via Renovate)
- **DuckDB Driver**: v0.4.1 (auto-updated via Renovate)
- **Base Image**: OpenJDK 19 JDK Slim

## License

This project is open source. Metabase and DuckDB driver have their respective licenses.
