#!/bin/bash

echo "Running Prisma Migrations for Excalidraw"
echo "======================================="

# Check if database exists and is accessible
echo "Testing database connection..."
PGPASSWORD=Ansberga1 psql -h localhost -U devuser -d excalidraw_db -c "SELECT 1" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ Cannot connect to database. Please run: sudo bash setup-postgres.sh"
    exit 1
fi

echo "✅ Database connection successful"

# Generate Prisma client
echo ""
echo "Generating Prisma client..."
npx prisma generate

# Run migrations
echo ""
echo "Running database migrations..."
npx prisma migrate deploy

# Show migration status
echo ""
echo "Current migration status:"
npx prisma migrate status

echo ""
echo "✅ Migrations complete!"