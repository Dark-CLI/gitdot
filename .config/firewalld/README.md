# Firewalld Configuration

Personal firewall setup for Fedora with Cloudflare Zero Trust VPN access:
- Services only accessible via Cloudflare Zero Trust WARP + tunnel
- LAN gateway (10.95.12.95) for legacy access
- Stealth mode (invisible to ping)
- Docker service isolation

## Quick Commands

```bash
# Apply config changes
~/.config/firewalld/update.sh

# Check status
firewall-cmd --list-all
```

## Current Setup

### Services on 10.0.0.0/24 Network

| Service | IP | Port | Access |
|---------|----|----|--------|
| Cloudflared (tunnel) | 10.0.0.2 | - | WARP tunnel |
| Ollama | 10.0.0.3 | 3001 | Via WARP |
| Open-WebUI | 10.0.0.4 | 3002 | Via WARP |
| Navidrome | 10.0.0.5 | 3000 | Via WARP |
| OpenSpeedtest | 10.0.0.6 | 3003 | Via WARP |

### Firewall Rules

#### Public Zone (enp9s0 - external LAN)
- Allow: Cloudflare tunnel to 10.0.0.0/24 (via policy)
- Allow: LAN gateway (10.95.12.95) SSH/Mosh
- Block: Everything else
- Stealth: Drop ICMP ping

#### Docker Zone (docker0, br-*)
- Accept: All Docker internal traffic
- Trusted for container-to-container communication

#### Policies
- `public-to-docker`: Routes traffic from LAN gateway to services

## Access Methods

### Via Cloudflare Zero Trust WARP
1. Connect WARP on phone/laptop
2. Access services by IP:
   - `http://10.0.0.5:3000` (Navidrome)
   - `http://10.0.0.3:3001` (Ollama)
   - `http://10.0.0.4:3002` (Open-WebUI)
   - `http://10.0.0.6:3003` (OpenSpeedtest)

### Via LAN Gateway (legacy)
- SSH: `10.95.12.95:22`
- Mosh: `10.95.12.95:60000-61000`

## How It Works

1. **Cloudflare Zero Trust** authenticates users
2. **Cloudflared tunnel** (10.0.0.2) connects to Cloudflare
3. **WARP client** on your device routes traffic through tunnel
4. **Firewall** allows 10.0.0.0/24 traffic (via public-to-docker policy)
5. **Docker** routes to services

## Architecture

```
Your Phone (WARP connected)
    ↓
Cloudflare network
    ↓
cloudflared tunnel (10.0.0.2)
    ↓
10.0.0.0/24 Services Network
    ├── 10.0.0.3:3001 (Ollama)
    ├── 10.0.0.4:3002 (Open-WebUI)
    ├── 10.0.0.5:3000 (Navidrome)
    └── 10.0.0.6:3003 (OpenSpeedtest)
```

## Files

| Location | Purpose |
|----------|---------|
| `~/.config/firewalld/zones/public.xml` | External interface rules |
| `~/.config/firewalld/zones/docker.xml` | Docker network rules |
| `~/.config/firewalld/policies/public-to-docker.xml` | LAN gateway to services routing |
| `/etc/firewalld/` | Active firewall config |

## Troubleshooting

```bash
# View current rules
firewall-cmd --zone=public --list-all

# View policies
firewall-cmd --get-policies

# View Docker chain
sudo iptables -L DOCKER -v -n

# Reload after changes
~/.config/firewalld/update.sh
```
