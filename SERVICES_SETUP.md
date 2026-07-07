# Services Setup - Complete Documentation

## Overview
Local services (Navidrome, Ollama, Open-WebUI, OpenSpeedtest) accessible via:
- **Cloudflare Zero Trust WARP** (remote)
- **Mikrotik LAN Router** (local LAN)

Both access services via **domain names** (e.g., `https://navidrome.home`)

---

## Architecture

### Network Layout
```
WARP Clients (Remote)
    ↓
Cloudflare Tunnel (10.0.0.2)
    ↓
Linux Server (10.95.12.46)
    ├── Docker Services Network (10.0.0.0/24)
    │   ├── dnsmasq (10.0.0.254) - DNS resolver
    │   ├── Nginx (10.0.0.100) - Reverse proxy (ports 80/443)
    │   ├── Navidrome (10.0.0.5:3005)
    │   ├── Ollama (10.0.0.3:11434)
    │   ├── Open-WebUI (10.0.0.4:8080)
    │   └── OpenSpeedtest (10.0.0.6:3000, 3001)
    │
    └── LAN Network (10.95.x.x)
        └── Mikrotik Router (10.95.12.95)
```

### Data Flow

#### WARP Clients (Remote)
1. Client queries DNS via **Zero Trust DNS Fallback** → `10.0.0.254` (dnsmasq)
2. dnsmasq resolves `.home` domains → `10.0.0.100` (Nginx IP)
3. Traffic routed through Cloudflare tunnel to Linux server
4. Nginx proxies to internal Docker services
5. HTTP automatically redirects to HTTPS

#### Mikrotik/LAN (Local)
1. Mikrotik DNS static entries resolve `.home` domains → `10.95.12.46` (Linux server IP)
2. Requests connect to:
   - Port 80/443 (Nginx) for UI services
   - Port 3006/3007 (direct) for OpenSpeedtest
3. Firewall allows traffic from 10.95.12.95 to services

---

## Services Configuration

### 1. dnsmasq (DNS Resolver)
- **Container IP**: 10.0.0.254
- **Port**: 53 (UDP)
- **Function**: Resolve `.home` domains to service IPs
- **Config**: `~/.local/coredns/dnsmasq.conf`
- **Entries**:
  ```
  navidrome.home → 10.0.0.100
  ollama.home → 10.0.0.100
  open-webui.home → 10.0.0.100
  openspeedtest.home → 10.0.0.100
  ```

### 2. Nginx (Reverse Proxy)
- **Container IP**: 10.0.0.100
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **Features**:
  - Self-signed SSL certificates for `*.home`
  - HTTP→HTTPS auto-redirect
  - Name-based virtual hosting
  - WebSocket support (for Open-WebUI)
- **Config**: `~/.local/nginx/nginx.conf`

#### Nginx Service Mappings
| Domain | Backend | Port | Status |
|--------|---------|------|--------|
| navidrome.home | 10.0.0.5:3005 | 443 | ✅ Working |
| ollama.home | 10.0.0.3:11434 | 443 | ✅ Working |
| open-webui.home / webui.home | 10.0.0.4:8080 | 443 | ✅ Working |
| openspeedtest.home | 10.0.0.6:3000 | 443 | ⚠️ UI only (glitch) |

### 3. Navidrome (Music Server)
- **Container IP**: 10.0.0.5
- **Internal Port**: 3005
- **Access**: `https://navidrome.home`
- **Through Nginx**: ✅ Full proxy support

### 4. Ollama (LLM API)
- **Container IP**: 10.0.0.3
- **Internal Port**: 11434
- **Access**: `https://ollama.home`
- **Through Nginx**: ✅ Full proxy support

### 5. Open-WebUI (Web Interface)
- **Container IP**: 10.0.0.4
- **Internal Port**: 8080
- **Access**: `https://open-webui.home` or `https://webui.home`
- **Through Nginx**: ✅ Full proxy support (WebSocket enabled)

### 6. OpenSpeedtest (Speed Test Tool)
- **Container IP**: 10.0.0.6
- **Internal Ports**: 3000 (UI), 3001 (data)
- **Host Ports**: 3006 (maps to 3000), 3007 (maps to 3001)
- **Access**: 
  - UI: `https://openspeedtest.home:3006` (via Nginx)
  - Speed Test: Uses port 3007 directly for data connection
- **Note**: UI may show anomalous numbers (display glitch), but traffic transfers correctly

---

## Access Methods

### From WARP Clients (Remote)
1. Connect to **Cloudflare WARP**
2. Access via HTTPS (accept self-signed cert warning):
   ```
   https://navidrome.home
   https://ollama.home
   https://open-webui.home
   https://openspeedtest.home:3006
   ```

### From Mikrotik/LAN
1. Configure Mikrotik DNS static entries (see Mikrotik Setup section)
2. Access via HTTPS (accept self-signed cert warning):
   ```
   https://navidrome.home
   https://ollama.home
   https://open-webui.home
   https://openspeedtest.home:3006
   ```

---

## Configuration Files

| Location | Purpose |
|----------|---------|
| `~/.local/nginx/nginx.conf` | Nginx reverse proxy config |
| `~/.local/nginx/certs/wildcard.crt` | Self-signed SSL cert |
| `~/.local/nginx/certs/wildcard.key` | SSL private key |
| `~/.local/coredns/dnsmasq.conf` | DNS resolver config |
| `~/.config/firewalld/zones/public.xml` | Firewall rules |
| `~/.config/lazydot.toml` | Dotfile manager config |

---

## Firewall Rules

**Allowed traffic:**
- HTTP/HTTPS from 10.95.12.95 (Mikrotik) to 10.0.0.0/24 (services)
- DNS (UDP 53) from 10.95.12.95 to 10.0.0.254 (dnsmasq)
- OpenSpeedtest data (TCP 3001) from 10.95.12.95 to 10.0.0.6
- SSH/Mosh from Mikrotik for management

**Denied:**
- ICMP (ping) - Stealth mode enabled

---

## Mikrotik Setup

### DNS Configuration
```bash
# Add static DNS entries for .home domains
/ip dns static add name=navidrome.home address=10.95.12.46
/ip dns static add name=ollama.home address=10.95.12.46
/ip dns static add name=open-webui.home address=10.95.12.46
/ip dns static add name=webui.home address=10.95.12.46
/ip dns static add name=openspeedtest.home address=10.95.12.46
/ip dns static add name=speedtest.home address=10.95.12.46
```

### Routing Configuration
```bash
# Route 10.0.0.0/24 network through Linux server
/ip route add dst-address=10.0.0.0/24 gateway=10.95.12.46
```

---

## Known Issues & Workarounds

### OpenSpeedtest UI Display
- **Issue**: Upload speed shows anomalously high numbers
- **Cause**: JavaScript UI display glitch (frontend rendering issue)
- **Status**: Data transfer working correctly (traffic confirmed on server)
- **Workaround**: Monitor actual network traffic on server, not UI display

### SSL Certificate Warnings
- **Issue**: Browser warns about self-signed certificate
- **Cause**: Certificates not signed by trusted CA
- **Workaround**: Click "Advanced" → "Proceed anyway" (safe for internal use)

---

## Maintenance

### Restart Services
```bash
# Restart Nginx
cd ~/.local/nginx && docker-compose restart

# Restart dnsmasq
cd ~/.local/coredns && docker-compose restart

# Restart OpenSpeedtest
cd ~/.local/openspeedtest && docker-compose restart
```

### Update Firewall Rules
```bash
~/.config/firewalld/update.sh
```

### View Logs
```bash
docker logs nginx
docker logs dnsmasq
docker logs openspeedtest
```

---

## Testing

### From WARP
```bash
# Test DNS resolution
nslookup navidrome.home

# Test HTTP access (auto-redirects to HTTPS)
curl -k https://navidrome.home
```

### From Mikrotik
```bash
# Test DNS resolution
nslookup navidrome.home

# Test HTTP access
/tool fetch url=https://navidrome.home verbose=yes
```

---

## Git Commits
All configuration managed in git. 15 commits tracking:
- DNS setup (dnsmasq)
- Nginx reverse proxy with SSL
- Static IP assignments for services
- Firewall rules for LAN access
- HTTP→HTTPS redirects
- WebSocket support for Open-WebUI
- OpenSpeedtest configuration
- Body size limits for file uploads

---

**Last Updated**: 2026-07-07
**Status**: ✅ Production Ready (All services working)
