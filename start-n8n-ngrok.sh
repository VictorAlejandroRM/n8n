#!/bin/bash

# ===============================
# 🔧 Configuración
# ===============================

# Token de ngrok (cámbialo por el tuyo)
NGROK_TOKEN="30NSIWSbh5pJgcxK6RrefsPc2Qo_2c7vh1G88dfaE2WnT8PoK"

# Puerto interno de n8n
N8N_PORT=5678

# ===============================
# 🗂️ Crear carpetas persistentes
# ===============================
mkdir -p n8n_data n8n_output

# ===============================
# 🐳 Iniciar n8n en segundo plano
# ===============================
echo "🔄 Iniciando n8n..."
docker run -d \
  --name n8n-dev \
  -p $N8N_PORT:$N8N_PORT \
  -v "$(pwd)/n8n_data:/home/node/.n8n" \
  -v "$(pwd)/n8n_output:/data" \
  n8nio/n8n

sleep 3

# ===============================
# 🧪 Verificar si ngrok está instalado
# ===============================
if ! command -v ngrok &> /dev/null
then
  echo "📦 ngrok no encontrado, instalando..."
  npm install -g ngrok
fi

# ===============================
# 🔐 Autenticarse con ngrok
# ===============================
echo "🔐 Autenticando ngrok..."
ngrok config add-authtoken "$NGROK_TOKEN"

# ===============================
# 🌍 Iniciar túnel
# ===============================
echo "🌍 Abriendo túnel ngrok al puerto $N8N_PORT..."
ngrok http $N8N_PORT > /dev/null &

# Esperar unos segundos para que ngrok inicie
sleep 5

# Obtener y mostrar la URL pública
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o 'https://[^"]*' | head -n 1)

echo ""
echo "✅ n8n está corriendo en Codespaces."
echo "🌐 Webhook público (URL externa): $NGROK_URL"
echo "ℹ️ Usa esta URL en servicios como GitHub, Stripe, etc."
echo ""

