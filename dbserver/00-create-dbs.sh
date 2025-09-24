#!/bin/bash
set -e

echo "Initializing multiple databases and users (with optional PostGIS)..."

DEFAULT_DB="${POSTGRES_DB:-postgres}"

# Parse DB_LIST from environment
IFS=',' read -ra DBS <<< "$DB_LIST"
for db in "${DBS[@]}"; do
    IFS=':' read -ra PARTS <<< "$db"
    DB_NAME="${PARTS[0]}"
    DB_USER="${PARTS[1]}"
    DB_PASS="${PARTS[2]}"
    DB_TYPE="${PARTS[3]:-nogis}"   # default to 'nogis' if missing

    echo "Ensuring user '$DB_USER' exists"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$DEFAULT_DB" <<-EOSQL
        DO \$\$
        BEGIN
            IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$DB_USER') THEN
                CREATE USER $DB_USER WITH ENCRYPTED PASSWORD '$DB_PASS';
            END IF;
        END
        \$\$;
EOSQL

    echo "Ensuring database '$DB_NAME' exists"
    DB_EXISTS=$(psql -qtAX --username "$POSTGRES_USER" --dbname "$DEFAULT_DB" -c "SELECT 1 FROM pg_database WHERE datname='$DB_NAME';")
    if [[ "$DB_EXISTS" != "1" ]]; then
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$DEFAULT_DB" -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
    fi

    echo "Granting privileges on '$DB_NAME'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$DB_NAME" <<-EOSQL
        -- Make sure user owns the public schema
        ALTER SCHEMA public OWNER TO $DB_USER;

        -- Grant privileges on existing objects
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USER;
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;
        GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO $DB_USER;

        -- Ensure future objects are also owned/granted
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $DB_USER;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $DB_USER;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO $DB_USER;
EOSQL

    if [[ "$DB_TYPE" == "gis" ]]; then
        echo "Enabling PostGIS on '$DB_NAME'"
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$DB_NAME" <<-EOSQL
            CREATE EXTENSION IF NOT EXISTS postgis;
            CREATE EXTENSION IF NOT EXISTS postgis_topology;
EOSQL
    fi
done
