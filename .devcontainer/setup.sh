#!/bin/bash

# Install PostgreSQL
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib

# Start PostgreSQL service
sudo service postgresql start

# Set password for the postgres user
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'yourpassword';"

# Create a new database
sudo -u postgres createdb mydatabase

echo "PostgreSQL has been installed, and the 'postgres' user password has been set. Database 'mydatabase' created."
