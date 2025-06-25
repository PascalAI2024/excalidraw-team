#!/bin/bash

echo "PostgreSQL Setup Script for Excalidraw"
echo "======================================"

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run this script with sudo: sudo bash setup-postgres.sh"
    exit 1
fi

# Switch to postgres user and create database and user
sudo -u postgres psql << EOF
-- Create user if not exists
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'devuser') THEN
      CREATE USER devuser WITH PASSWORD 'Ansberga1';
      RAISE NOTICE 'User devuser created';
   ELSE
      ALTER USER devuser WITH PASSWORD 'Ansberga1';
      RAISE NOTICE 'User devuser password updated';
   END IF;
END
\$\$;

-- Create database if not exists
SELECT 'CREATE DATABASE excalidraw_db OWNER devuser'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'excalidraw_db')\gexec

-- Grant all privileges
GRANT ALL PRIVILEGES ON DATABASE excalidraw_db TO devuser;

-- Show results
\du devuser
\l excalidraw_db
EOF

echo ""
echo "Testing connection..."
PGPASSWORD=Ansberga1 psql -h localhost -U devuser -d excalidraw_db -c "SELECT current_database(), current_user, version();" && echo "✅ Connection successful!" || echo "❌ Connection failed"

echo ""
echo "Setup complete. You can now run Prisma migrations."