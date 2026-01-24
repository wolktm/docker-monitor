#!/bin/bash
echo "=== SSH TUNNEL DEBUGGING ==="
echo ""
echo "1. Which ports is Portainer container actually using?"
docker ps --filter "name=portainer" --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}"
echo ""
echo "2. Is anything listening on port 9000?"
sudo netstat -tlnp | grep :9000 || echo "Nothing listening on port 9000"
echo ""
echo "3. Is anything listening on port 9443?"
sudo netstat -tlnp | grep :9443 || echo "Nothing listening on port 9443"
echo ""
echo "4. Can we access port 9000 locally on VPS?"
curl -I http://localhost:9000 2>&1 | head -5
echo ""
echo "5. Can we access port 9443 locally on VPS?"
curl -Ik https://localhost:9443 2>&1 | head -5
echo ""
echo "6. Portainer service status:"
docker service ps portainer_portainer --no-trunc
