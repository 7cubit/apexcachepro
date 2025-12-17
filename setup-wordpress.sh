#!/bin/bash

# ApexCache WordPress Setup Script
# This script sets up WordPress with Docker and installs the ApexCache plugin

set -e

echo "🚀 Starting ApexCache WordPress Setup..."
echo ""

# Start Docker containers
echo "📦 Starting Docker containers..."
docker-compose up -d

echo "⏳ Waiting for WordPress to be ready (30 seconds)..."
sleep 30

# Install Composer dependencies in the plugin
echo "📥 Installing Composer dependencies..."
docker-compose exec -T wordpress bash -c "cd /var/www/html/wp-content/plugins/apex-cache && composer install --no-dev"

# Install WordPress via WP-CLI
echo "🔧 Installing WordPress..."
docker-compose exec -T wpcli wp core install \
  --url="http://localhost:8080" \
  --title="ApexCache Test Site" \
  --admin_user="admin" \
  --admin_password="admin123" \
  --admin_email="admin@example.com" \
  --skip-email

# Activate ApexCache plugin
echo "🔌 Activating ApexCache plugin..."
docker-compose exec -T wpcli wp plugin activate apex-cache

# Configure Redis in wp-config.php
echo "⚙️  Configuring Redis..."
docker-compose exec -T wpcli wp config set WP_REDIS_HOST redis --type=constant
docker-compose exec -T wpcli wp config set WP_REDIS_PORT 6379 --type=constant --raw
docker-compose exec -T wpcli wp config set WP_REDIS_DATABASE 0 --type=constant --raw

# Test Redis connection
echo "🧪 Testing Redis connection..."
docker-compose exec -T wpcli wp apexcache test

# Display statistics
echo "📊 Cache Statistics:"
docker-compose exec -T wpcli wp apexcache info

echo ""
echo "✅ Setup Complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  WordPress is running at: http://localhost:8080"
echo "  Admin URL: http://localhost:8080/wp-admin"
echo "  Username: admin"
echo "  Password: admin123"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Useful Commands:"
echo "  View logs:        docker-compose logs -f wordpress"
echo "  Stop containers:  docker-compose down"
echo "  Restart:          docker-compose restart"
echo "  WP-CLI:           docker-compose exec wpcli wp [command]"
echo "  ApexCache stats:  docker-compose exec wpcli wp apexcache stats"
echo ""
