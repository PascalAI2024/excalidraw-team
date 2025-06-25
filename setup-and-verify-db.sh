#!/bin/bash

echo "Excalidraw Database Setup and Verification"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Database configuration
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="excalidraw_db"
DB_USER="devuser"
DB_PASS="Ansberga1"

# Step 1: Check PostgreSQL service
echo "1. Checking PostgreSQL service..."
if pg_isready -h $DB_HOST -p $DB_PORT > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PostgreSQL is running${NC}"
else
    echo -e "${RED}❌ PostgreSQL is not running${NC}"
    echo "Please start PostgreSQL with: sudo systemctl start postgresql"
    exit 1
fi

# Step 2: Test connection with devuser
echo ""
echo "2. Testing database connection..."
PGPASSWORD=$DB_PASS psql -h $DB_HOST -U $DB_USER -d postgres -c "SELECT 1" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ User 'devuser' exists and can connect${NC}"
else
    echo -e "${YELLOW}⚠️  Cannot connect with devuser. Database/user might not exist.${NC}"
    echo ""
    echo "To set up the database and user, run:"
    echo -e "${YELLOW}sudo bash setup-postgres.sh${NC}"
    echo ""
    echo "After that, run this script again."
    exit 1
fi

# Step 3: Check if database exists
echo ""
echo "3. Checking if database 'excalidraw_db' exists..."
PGPASSWORD=$DB_PASS psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT 1" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database 'excalidraw_db' exists${NC}"
else
    echo -e "${RED}❌ Database 'excalidraw_db' does not exist${NC}"
    echo "Please run: sudo bash setup-postgres.sh"
    exit 1
fi

# Step 4: Check Prisma installation
echo ""
echo "4. Checking Prisma installation..."
if npx prisma --version > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Prisma is installed${NC}"
    npx prisma --version | head -1
else
    echo -e "${RED}❌ Prisma is not installed${NC}"
    echo "Installing Prisma..."
    npm install --save-dev prisma @prisma/client
fi

# Step 5: Generate Prisma Client
echo ""
echo "5. Generating Prisma Client..."
npx prisma generate
echo -e "${GREEN}✅ Prisma Client generated${NC}"

# Step 6: Check migration status
echo ""
echo "6. Checking migration status..."
npx prisma migrate status

# Step 7: Deploy migrations if needed
echo ""
echo "7. Deploying pending migrations..."
npx prisma migrate deploy

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ All migrations deployed successfully${NC}"
else
    echo -e "${RED}❌ Migration deployment failed${NC}"
    exit 1
fi

# Step 8: Verify tables exist
echo ""
echo "8. Verifying database tables..."
TABLES=$(PGPASSWORD=$DB_PASS psql -h $DB_HOST -U $DB_USER -d $DB_NAME -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;")

if echo "$TABLES" | grep -q "User" && echo "$TABLES" | grep -q "Drawing" && echo "$TABLES" | grep -q "Share"; then
    echo -e "${GREEN}✅ All required tables exist:${NC}"
    echo "$TABLES" | sed 's/^/  - /'
else
    echo -e "${RED}❌ Some tables are missing${NC}"
    echo "Found tables:"
    echo "$TABLES" | sed 's/^/  - /'
    exit 1
fi

# Step 9: Show database info
echo ""
echo "9. Database Information:"
echo "========================"
PGPASSWORD=$DB_PASS psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "
SELECT 
    current_database() as database,
    current_user as user,
    pg_database_size(current_database())/1024/1024 as size_mb,
    (SELECT count(*) FROM pg_stat_user_tables) as table_count
;"

echo ""
echo -e "${GREEN}✅ Database setup is complete and verified!${NC}"
echo ""
echo "Connection string: postgresql://$DB_USER:$DB_PASS@$DB_HOST:$DB_PORT/$DB_NAME"
echo ""
echo "You can now start your application!"