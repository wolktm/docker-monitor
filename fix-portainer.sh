#!/bin/bash
# Fix Portainer deployment by removing and redeploying

set -e

echo "=== FIXING PORTAINER DEPLOYMENT ==="
echo ""

# Step 1: Remove the stack
echo "1. Removing existing Portainer stack..."
docker stack rm portainer

# Step 2: Wait for complete shutdown
echo ""
echo "2. Waiting for all containers to stop (30 seconds)..."
sleep 10
echo "   - 10 seconds..."
sleep 10
echo "   - 20 seconds..."
sleep 10
echo "   - 30 seconds..."

# Step 3: Verify no portainer containers are running
echo ""
echo "3. Checking for remaining containers..."
REMAINING=$(docker ps -a | grep portainer || true)
if [ -n "$REMAINING" ]; then
    echo "WARNING: Some portainer containers still exist:"
    echo "$REMAINING"
    echo ""
    echo "Waiting another 10 seconds..."
    sleep 10
fi

# Step 4: Check if database is accessible
echo ""
echo "4. Checking database file..."
if [ -f /opt/data/portainer/portainer.db ]; then
    echo "   Database file exists: /opt/data/portainer/portainer.db"
    ls -lh /opt/data/portainer/portainer.db
else
    echo "   WARNING: Database file not found!"
fi

# Step 5: Redeploy with new config
echo ""
echo "5. Redeploying Portainer stack..."
docker stack deploy -c docker-stack.portainer.yml portainer

# Step 6: Wait for service to start
echo ""
echo "6. Waiting for Portainer to start (30 seconds)..."
sleep 30

# Step 7: Check service status
echo ""
echo "7. Checking service status..."
docker service ps portainer_portainer --no-trunc

echo ""
echo "8. Recent logs:"
docker service logs portainer_portainer --tail 10

echo ""
echo "9. Setting up iptables rules for port 9000..."
# Remove old rules for both 9000 and 9443
sudo iptables -D DOCKER-USER -i lo -p tcp --dport 9000 -j ACCEPT 2>/dev/null || true
sudo iptables -D DOCKER-USER -p tcp --dport 9000 -j DROP 2>/dev/null || true
sudo iptables -D DOCKER-USER -i lo -p tcp --dport 9443 -j ACCEPT 2>/dev/null || true
sudo iptables -D DOCKER-USER -p tcp --dport 9443 -j DROP 2>/dev/null || true

# Add new rules for port 9000
sudo iptables -I DOCKER-USER 1 -i lo -p tcp --dport 9000 -j ACCEPT
sudo iptables -I DOCKER-USER 2 -p tcp --dport 9000 -j DROP

echo ""
echo "Current DOCKER-USER iptables rules for port 9000:"
sudo iptables -L DOCKER-USER -n -v | grep 9000

echo ""
echo "=== FIX COMPLETE ==="
echo ""
echo "Portainer should now be running on port 9000 (HTTP)"
echo ""
echo "To access via SSH tunnel:"
echo "  ssh -L 9000:127.0.0.1:9000 user@your-vps-ip"
echo "  Then open: http://localhost:9000"
echo ""
echo "Verify with:"
echo "  docker ps | grep portainer"
echo "  curl -I http://localhost:9000"
