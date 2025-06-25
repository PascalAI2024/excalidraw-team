#!/bin/bash

# Start backend server in background
echo "Starting backend server on port 3001..."
cd server && npm run dev &
BACKEND_PID=$!

# Wait a moment for backend to initialize
sleep 3

# Start frontend app
echo "Starting frontend app on port 5173..."
cd /home/pascal/excalidraw && npm run start

# When frontend is stopped, also stop backend
trap "kill $BACKEND_PID" EXIT