#!/bin/bash
# Deploy Portainer to Docker Swarm with localhost-only access

set -e

echo "=== Portainer Deployment for Docker Swarm ==="
echo ""

# Create data directory
echo "1. Creating Portainer data directory..."
sudo mkdir -p /opt/data/portainer
sudo chown -R root:root /opt/data/portainer
sudo chmod 700 /opt/data/portainer

# Deploy the stack
echo ""
echo "2. Deploying Portainer stack..."
docker stack deploy -c docker-stack.portainer.yml portainer

# Wait for service to start
echo ""
echo "3. Waiting for Portainer to start (30 seconds)..."
sleep 30

# Setup iptables rules for localhost-only access
echo ""
echo "4. Setting up iptables rules for localhost-only access..."

# Remove existing rules for port 9443 if they exist (order matters)
sudo iptables -D DOCKER-USER -i lo -p tcp --dport 9443 -j ACCEPT 2>/dev/null || true
sudo iptables -D DOCKER-USER -p tcp --dport 9443 -j DROP 2>/dev/null || true

# Add new rules with explicit positions (ACCEPT at pos 1, DROP at pos 2)
# This ensures localhost is allowed before everything else is dropped
sudo iptables -I DOCKER-USER 1 -i lo -p tcp --dport 9443 -j ACCEPT
sudo iptables -I DOCKER-USER 2 -p tcp --dport 9443 -j DROP

# Show the rules
echo ""
echo "Current DOCKER-USER iptables rules for port 9443:"
sudo iptables -L DOCKER-USER -n -v | grep 9443

# Ask about persistence
echo ""
echo "=== Deployment Complete! ==="
echo ""
echo "Portainer is now running and secured to localhost-only access."
echo ""
echo "To access Portainer via SSH tunnel:"
echo "  ssh -L 9443:127.0.0.1:9443 user@your-vps-ip"
echo "  Then open: https://localhost:9443"
echo ""
echo "To persist iptables rules across reboots:"
echo "  sudo apt install iptables-persistent"
echo "  sudo netfilter-persistent save"
echo ""
echo "Check service status:"
echo "  docker service ls | grep portainer"
echo "  docker service logs portainer_portainer -f"
