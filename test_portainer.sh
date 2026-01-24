#!/bin/bash
echo "=== TESTING PORTAINER ACCESS ==="
echo ""
echo "1. Test HTTPS access to running Portainer:"
curl -Ik https://localhost:9443 2>&1 | head -10
echo ""
echo "2. Running Portainer container logs:"
docker logs --tail 20 75beebae9fa4
echo ""
echo "3. Container status:"
docker inspect 75beebae9fa4 | jq '{
  Name: .[0].Name,
  State: .[0].State.Status,
  Health: .[0].State.Health // "no healthcheck"
}'
