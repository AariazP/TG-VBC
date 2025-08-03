#!/bin/bash

# Parámetros
NETWORK_NAME="vm-net-30"
SUBNET="172.30.30.0/24"
GATEWAY="172.30.30.1"
HOST_IF_NAME="host-vif-vmnet30"
OUT_INTERFACE="eth0"  # Interfaz que tiene salida a internet

# Crear red interna sin bridge
echo "🧱 Creando red virtual sin bridge..."
xe network-create name-label="$NETWORK_NAME"

# Obtener UUID de la red
NET_UUID=$(xe network-list name-label="$NETWORK_NAME" --minimal)

if [ -z "$NET_UUID" ]; then
    echo "❌ Error: no se pudo crear o encontrar la red."
    exit 1
fi

echo "✅ Red creada con UUID: $NET_UUID"

# Crear interfaz virtual del host (para que actúe como gateway)
HOST_UUID=$(xe host-list --minimal)

echo "🧩 Agregando interfaz virtual al host..."
xe vif-create network-uuid=$NET_UUID device=0 vm-uuid=$HOST_UUID MAC=random

# Asignar IP al bridge virtual (creado por Xen automáticamente)
BRIDGE_IF=$(xe network-param-get param-name=bridge uuid=$NET_UUID)
echo "🌐 Asignando IP $GATEWAY al bridge $BRIDGE_IF..."
ip addr add $GATEWAY/24 dev $BRIDGE_IF
ip link set dev $BRIDGE_IF up

# Habilitar reenvío de IPs
echo "🚦 Habilitando IP forwarding..."
sysctl -w net.ipv4.ip_forward=1
sed -i '/^#net.ipv4.ip_forward=1/c\net.ipv4.ip_forward=1' /etc/sysctl.conf

# Configurar NAT para salida a internet
echo "🔁 Configurando NAT con iptables..."
iptables -t nat -A POSTROUTING -s $SUBNET -o $OUT_INTERFACE -j MASQUERADE
iptables -A FORWARD -s $SUBNET -j ACCEPT

# Guardar reglas si usas iptables-persistent
if command -v netfilter-persistent &> /dev/null; then
    echo "💾 Guardando reglas iptables (netfilter-persistent)..."
    netfilter-persistent save
elif command -v iptables-save &> /dev/null; then
    echo "💾 Puedes guardar reglas con: sudo iptables-save > /etc/iptables/rules.v4"
fi

echo "✅ Configuración completada. Las VMs conectadas a '$NETWORK_NAME' con IPs en $SUBNET podrán salir a internet vía $OUT_INTERFACE."

