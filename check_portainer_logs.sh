#!/bin/bash
echo "=== PORTAINER SERVICE LOGS ==="
echo ""
echo "Recent service logs (last 50 lines):"
docker service logs portainer_portainer --tail 50
