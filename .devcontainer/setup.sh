#!/bin/bash

echo "Starting PostgreSQL and Django environment setup..."

# Install PostgreSQL
echo "Updating package list..."
sudo apt-get update || { echo "Failed to update package list"; exit 1; }
echo "Installing PostgreSQL and Python..."
sudo apt-get install -y postgresql postgresql-contrib python3 python3-pip || { echo "Failed to install PostgreSQL and Python"; exit 1; }

# Start PostgreSQL service
echo "Starting PostgreSQL service..."
sudo service postgresql start || { echo "Failed to start PostgreSQL service"; exit 1; }

# Set password for the postgres user
POSTGRES_PASSWORD="potato"  # Replace with your desired password
echo "Setting PostgreSQL password..."
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${POSTGRES_PASSWORD}';" || { echo "Failed to set password for postgres user"; exit 1; }

# Create a new PostgreSQL database
DB_NAME="mydatabase1"
echo "Creating PostgreSQL database '$DB_NAME'..."
sudo -u postgres createdb $DB_NAME || { echo "Failed to create database '$DB_NAME'"; exit 1; }

# Install Django and psycopg2
echo "Installing Django and psycopg2..."
pip3 install django psycopg2-binary || { echo "Failed to install Django and psycopg2"; exit 1; }

# Create a new Django project if it doesn't exist
PROJECT_NAME="myproject"
if [ ! -d "$PROJECT_NAME" ]; then
    echo "Creating Django project '$PROJECT_NAME'..."
    django-admin startproject $PROJECT_NAME . || { echo "Failed to create Django project"; exit 1; }
else
    echo "Django project '$PROJECT_NAME' already exists."
fi

# Update Django settings to connect to PostgreSQL
SETTINGS_FILE="$PROJECT_NAME/settings.py"
if [ -f "$SETTINGS_FILE" ]; then
    echo "Updating Django settings to use PostgreSQL..."
    sed -i "s/ENGINE': 'django.db.backends.sqlite3'/ENGINE': 'django.db.backends.postgresql'/" $SETTINGS_FILE
    sed -i "/'ENGINE': 'django.db.backends.postgresql'/a\        'NAME': '$DB_NAME',\n        'USER': 'postgres',\n        'PASSWORD': '$POSTGRES_PASSWORD',\n        'HOST': 'localhost',\n        'PORT': '5432'," $SETTINGS_FILE
fi

# Run Django migrations
echo "Running Django migrations..."
python3 manage.py migrate || { echo "Failed to apply Django migrations"; exit 1; }

# Create superuser
echo "Creating Django superuser..."
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'adminpass')" | python3 manage.py shell || { echo "Failed to create superuser"; exit 1; }

echo "Django environment setup completed successfully."
