#!/bin/bash

echo "🧹 Starting EC2 cleanup..."

# SSH to server and run cleanup
ssh -i ansible/server_key ubuntu@54.167.107.133 << 'REMOTE_COMMANDS'

set -e  # Exit on error

echo "Step 1/7: Stopping containers..."
cd /opt/cloud1 2>/dev/null && sudo docker-compose down -v || true
sudo docker stop $(sudo docker ps -aq) 2>/dev/null || true

echo "Step 2/7: Removing containers..."
sudo docker container prune -af

echo "Step 3/7: Removing images..."
sudo docker image prune -af

echo "Step 4/7: Removing volumes..."
sudo docker volume prune -af

echo "Step 5/7: Removing networks..."
sudo docker network prune -f

echo "Step 6/7: Removing application directory..."
sudo rm -rf /opt/cloud1

echo "Step 7/7: Final cleanup..."
sudo docker system prune -a --volumes -f

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "Verification:"
echo "Containers: $(sudo docker ps -a | wc -l)"
echo "Images: $(sudo docker images | wc -l)"
echo "Volumes: $(sudo docker volume ls | wc -l)"
echo "Cloud1 dir: $(ls -d /opt/cloud1 2>/dev/null || echo 'Removed ✓')"
echo ""
df -h / | tail -1

REMOTE_COMMANDS

echo ""
echo "🎉 Server is ready for fresh deployment!"
echo ""
echo "To deploy fresh, run:"
echo "  cd ansible && ansible-playbook playbook.yml"
