#!/bin/bash

echo "Starting PostgreSQL and Django environment setup..."

# Install PostgreSQL
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib python3 python3-pip

# Start PostgreSQL service
sudo service postgresql start
echo "PostgreSQL service started."

# Set password for the postgres user
POSTGRES_PASSWORD="potato"  # Replace with your desired password
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${POSTGRES_PASSWORD}';"
echo "Password for postgres user set to '${POSTGRES_PASSWORD}'."

# Create a new PostgreSQL database
DB_NAME="mydatabase1"
sudo -u postgres createdb $DB_NAME
echo "Database '$DB_NAME' created."

# Install Django and psycopg2 (PostgreSQL adapter for Python)
pip3 install django psycopg2-binary
echo "Django and psycopg2 installed."

# Create a new Django project if it doesn't exist
PROJECT_NAME="myproject"
if [ ! -d "$PROJECT_NAME" ]; then
    django-admin startproject $PROJECT_NAME .
    echo "Django project '$PROJECT_NAME' created."
else
    echo "Django project '$PROJECT_NAME' already exists."
fi

# Update Django settings to connect to PostgreSQL
SETTINGS_FILE="$PROJECT_NAME/settings.py"
if [ -f "$SETTINGS_FILE" ]; then
    sed -i "s/ENGINE': 'django.db.backends.sqlite3'/ENGINE': 'django.db.backends.postgresql'/" $SETTINGS_FILE
    sed -i "/'ENGINE': 'django.db.backends.postgresql'/a\        'NAME': '$DB_NAME',\n        'USER': 'postgres',\n        'PASSWORD': '$POSTGRES_PASSWORD',\n        'HOST': 'localhost',\n        'PORT': '5432'," $SETTINGS_FILE
    echo "Django settings updated to use PostgreSQL."
fi

# Run Django migrations
python3 manage.py migrate
echo "Django migrations applied."

# Optional: create a superuser automatically
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'adminpass')" | python3 manage.py shell
echo "Superuser 'admin' created with password 'adminpass'."

echo "Django environment setup completed."
