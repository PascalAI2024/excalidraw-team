#!/bin/bash

# Excalidraw deployment management script

ACTION=$1

case $ACTION in
  "status")
    echo "=== Excalidraw Services Status ==="
    echo "Frontend (port 5173):"
    netstat -tlnp 2>/dev/null | grep :5173 || sudo netstat -tlnp | grep :5173
    echo ""
    echo "Backend (port 3001):"
    netstat -tlnp 2>/dev/null | grep :3001 || sudo netstat -tlnp | grep :3001
    echo ""
    echo "Docker Proxy Service:"
    docker service ls | grep excalidraw
    echo ""
    echo "Access URL: https://excalidraw.parlaymojo.com"
    ;;
    
  "logs")
    echo "=== Nginx Proxy Logs ==="
    docker service logs excalidraw_excalidraw-proxy --tail 50
    ;;
    
  "restart")
    echo "=== Restarting Docker Proxy Service ==="
    docker service update --force excalidraw_excalidraw-proxy
    ;;
    
  "deploy")
    echo "=== Deploying Excalidraw with Traefik ==="
    cd /home/pascal/dev/excalidraw
    docker stack deploy -c docker-compose.traefik.yml excalidraw
    ;;
    
  "remove")
    echo "=== Removing Excalidraw Docker Stack ==="
    docker stack rm excalidraw
    ;;
    
  *)
    echo "Usage: $0 {status|logs|restart|deploy|remove}"
    echo ""
    echo "Commands:"
    echo "  status  - Show status of all excalidraw services"
    echo "  logs    - Show nginx proxy logs"
    echo "  restart - Restart the Docker proxy service"
    echo "  deploy  - Deploy excalidraw stack with Traefik"
    echo "  remove  - Remove excalidraw Docker stack"
    exit 1
    ;;
esac