# CoreDNS for Hostname Resolution

Provides DNS resolution for `.home` domain, allowing you to access services by hostname through Cloudflare Zero Trust WARP.

## Setup

### 1. Start CoreDNS Container

```bash
cd ~/.local/coredns
docker-compose up -d
```

This starts CoreDNS on `10.0.0.1:53` with the services network.

### 2. Configure Cloudflare Gateway DNS

Go to **Cloudflare Zero Trust Dashboard** → **Gateway** → **DNS**:

1. Click **Create a DNS policy**
2. Set **Selector**: Domain → `Matches regex` → `.*\.home$`
3. Set **Action**: `Custom` → Select `Override` → Enter `10.0.0.1`
4. Save the policy

Alternative (simpler but less flexible):
- Go to **Settings** → **DNS** → **Custom resolvers**
- Add `10.0.0.1` on port `53` labeled "Internal"
- In policies, add: Domain `Matches regex` `.*\.home$` → Use `Internal` resolver

### 3. Access Services

Once configured, when connected to WARP, you can access:

```
http://navidrome.home:3005      # Navidrome music server
http://ollama.home:3003         # Ollama API
http://webui.home:3004          # Open-WebUI
http://speedtest.home:3006      # OpenSpeedtest
```

Or with aliases: `http://open-webui.home:3004`

## Corefile Configuration

The `Corefile` defines:
- `.home` zone with all internal services
- Fallthrough for other domains (CNAME, etc.)
- Forwarding to Cloudflare (1.1.1.1) and Google DNS (8.8.8.8) for non-.home queries
- Logging for debugging

To add new services, edit `Corefile` and restart:

```bash
docker-compose restart coredns
```

## Testing

From within the services network:

```bash
# Test from a container
docker exec -it navidrome nslookup navidrome.home 10.0.0.1

# Check CoreDNS logs
docker logs coredns
```

From your device connected to WARP:

```bash
nslookup navidrome.home
# Should resolve to 10.0.0.5
```

## Troubleshooting

- **DNS not resolving**: Check that CoreDNS is running (`docker ps`) and Cloudflare Gateway policy is active
- **Timeout on requests**: Ensure firewall allows UDP 53 from WARP clients (already configured)
- **Services not found**: Verify the IP address in `Corefile` matches `ipv4_address` in service docker-compose files
