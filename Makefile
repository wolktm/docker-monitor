.PHONY: help deploy-portainer remove-portainer logs-portainer setup-firewall cleanup-firewall

# Default target
help:
	@echo "Docker Stack Management"
	@echo "======================="
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy-portainer    - Deploy Portainer stack"
	@echo ""
	@echo "Removal:"
	@echo "  make remove-portainer    - Remove Portainer stack"
	@echo ""
	@echo "Monitoring:"
	@echo "  make logs-portainer      - Show Portainer logs"
	@echo ""
	@echo "Firewall:"
	@echo "  make setup-firewall      - Setup iptables for localhost-only access"
	@echo "  make cleanup-firewall    - Remove all iptables rules"

# Deployment targets
deploy-portainer:
	@echo "Deploying Portainer..."
	@mkdir -p /opt/data/portainer 2>/dev/null || sudo mkdir -p /opt/data/portainer
	docker stack deploy -c docker-stack.portainer.yml portainer
	@echo "Waiting 10 seconds for service to start..."
	@sleep 10
	@docker service ps portainer_portainer


# Removal targets
remove-portainer:
	@echo "Removing Portainer stack..."
	docker stack rm portainer
	@echo "Waiting for shutdown..."
	@sleep 10

# Monitoring targets
logs-portainer:
	@docker service logs portainer_portainer --tail 50 --follow

# Firewall targets
setup-firewall:
	@echo "Setting up iptables for localhost-only access to Portainer..."
	@sudo iptables -D DOCKER-USER -i lo -p tcp --dport 9000 -j ACCEPT 2>/dev/null || true
	@sudo iptables -D DOCKER-USER -p tcp --dport 9000 -j DROP 2>/dev/null || true
	@sudo iptables -D DOCKER-USER -i lo -p tcp --dport 9443 -j ACCEPT 2>/dev/null || true
	@sudo iptables -D DOCKER-USER -p tcp --dport 9443 -j DROP 2>/dev/null || true
	@sudo iptables -I DOCKER-USER 1 -i lo -p tcp --dport 9000 -j ACCEPT
	@sudo iptables -I DOCKER-USER 2 -p tcp --dport 9000 -j DROP
	@echo ""
	@echo "Current rules for port 9000:"
	@sudo iptables -L DOCKER-USER -n -v | grep 9000 || echo "No rules found"
	@echo ""
	@echo "To persist across reboots:"
	@echo "  sudo apt install iptables-persistent"
	@echo "  sudo netfilter-persistent save"

cleanup-firewall:
	@echo "Removing iptables rules for Portainer..."
	@sudo iptables -D DOCKER-USER -i lo -p tcp --dport 9000 -j ACCEPT 2>/dev/null || true
	@sudo iptables -D DOCKER-USER -p tcp --dport 9000 -j DROP 2>/dev/null || true
	@sudo iptables -D DOCKER-USER -i lo -p tcp --dport 9443 -j ACCEPT 2>/dev/null || true
	@sudo iptables -D DOCKER-USER -p tcp --dport 9443 -j DROP 2>/dev/null || true
	@echo "Firewall rules removed"

