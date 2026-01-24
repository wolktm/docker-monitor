# Portainer Quick Reference Guide

## Accessing Portainer

```bash
# From your laptop - create SSH tunnel
ssh -L 9443:127.0.0.1:9443 user@your-vps-ip

# Open in browser
https://localhost:9443
```

First login: Create admin password (12+ characters, recommended).

## Managing Your Stacks

### View Stacks
1. Left menu → **Stacks**
2. You'll see both `legaltech` and `kobu-service` stacks listed

### Update a Stack
1. Stacks → Select stack (e.g., `legaltech`)
2. Click **Editor** tab
3. Modify the docker-compose.yml
4. Click **Update the stack**

### Scale a Service
1. Services → Select service (e.g., `kobu-service_llm-worker`)
2. Click **Scale service**
3. Set replica count (e.g., from 1 to 2)
4. Click **Scale**

### View Logs
1. Services → Select service
2. Click **Logs** button (or Console for live logs)
3. Filter by task/replica if needed

### Restart a Service
1. Services → Select service
2. Click **Duplicate/Edit** → **Force update** → **Update**
   Or use quick actions: Click the service → **Restart**

## Common Tasks

### Check Resource Usage
- **Dashboard**: Overview of all containers, CPU, memory
- **Containers**: Detailed per-container metrics
- **Services**: Swarm service resource usage

### Access Container Console
1. Containers → Select container
2. Click **Console** button
3. Choose between **Connect** (bash/sh) or **Attach** (view output)

### Inspect Stack Issues
- Stacks → Select stack → Check service statuses
- Services → Look for failed tasks
- Click task ID → View logs and error messages

### Deploy a New Stack
1. Stacks → **Add stack**
2. Name: `my-new-stack`
3. Upload compose file or paste content
4. Click **Deploy the stack**

## Troubleshooting

### Service won't start
1. Services → Find service → Check **Tasks** tab
2. Look at failed tasks for error messages
3. Check logs: Services → Select service → **Logs**

### Portainer UI not accessible
```bash
# Check service is running
docker service ls | grep portainer

# Check service logs
docker service logs portainer_portainer -f

# Verify iptables rules
sudo iptables -L DOCKER-USER -n -v | grep 9443

# Verify port is listening
sudo netstat -tlnp | grep 9443
```

### Remove Portainer
```bash
docker stack rm portainer
# Remove iptables rules (order matters - remove DROP then ACCEPT)
sudo iptables -D DOCKER-USER -i lo -p tcp --dport 9443 -j ACCEPT
sudo iptables -D DOCKER-USER -p tcp --dport 9443 -j DROP
```

## Useful Portainer Features

### Endpoints
Can manage multiple Docker/Swarm clusters from one UI (not needed for single-node).

### Registries
Add Docker Hub or private registries for easy image pulls.

### Users & Teams
Add team members with role-based access (if managing with others).

### App Templates
Pre-built templates for common services (databases, CMS, etc.).
