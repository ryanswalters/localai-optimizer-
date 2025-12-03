#!/bin/bash

set -e

echo "=== Updating system packages ==="
sudo apt-get update -y
sudo apt-get install -y curl socat nginx

echo "=== Installing Tailscale ==="
curl -fsSL https://tailscale.com/install.sh | sh

echo "=== Starting Tailscale Daemon ==="
sudo systemctl enable --now tailscaled

echo " "
echo "==============================================================="
echo "Authenticate Tailscale in the browser that opens."
echo "==============================================================="
sudo tailscale up --ssh --advertise-exit-node

echo "=== Installing Ollama (snap version) ==="
sudo snap install ollama

echo "=== Verifying snap permissions ==="
sudo snap connect ollama:network
sudo snap connect ollama:network-bind

echo "=== Starting Ollama service ==="
sudo systemctl start snap.ollama.ollama.service
sudo systemctl enable snap.ollama.ollama.service

sleep 3

echo "=== Creating custom model directory ==="
mkdir -p ~/qwen30b
cd ~/qwen30b

echo "FROM hf.co/Merlinoz11/Qwen3-30B-A3B-python-coder-Q6_K-GGUF:Q6_K" > Modelfile

echo "=== Registering model with Ollama ==="
ollama create qwen30b -f Modelfile

echo "=== Pulling model weights (this may take a while) ==="
ollama pull qwen30b

echo " "
echo "========================= READY ==============================="
echo "Tailscale: Connected"
echo "Ollama: Running"
echo "Qwen 30B: Installed"
echo " "
echo "Run the model with:"
echo "    ollama run qwen30b"
echo "==============================================================="
