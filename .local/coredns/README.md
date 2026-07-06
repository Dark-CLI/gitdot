# dnsmasq for Hostname Resolution

Provides DNS resolution for `.home` domain, allowing you to access services by hostname through Cloudflare Zero Trust WARP.

## Setup

### 1. Start dnsmasq Container

```bash
cd ~/.local/coredns
docker-compose up -d
```

This starts dnsmasq on `10.0.0.254:53` with the services network.

### 2. Configure Cloudflare Gateway DNS

Go to **Cloudflare Zero Trust Dashboard** → **Gateway** → **DNS**:

1. Click **Create a DNS policy**
2. Set **Selector**: Domain → `Matches regex` → `.*\.home$`
3. Set **Action**: `Custom` → Select `Override` → Enter `10.0.0.254`
4. Save the policy

Alternative (simpler but less flexible):
- Go to **Settings** → **DNS** → **Custom resolvers**
- Add `10.0.0.254` on port `53` labeled "Internal"
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

## dnsmasq Configuration

The `dnsmasq.conf` defines:
- Address mappings for `.home` domain to service IPs
- Aliases (e.g., `webui.home` → `open-webui.home`)
- Forwarding to Cloudflare (1.1.1.1) and Google DNS (8.8.8.8) for external queries
- Query logging for debugging

To add new services, edit `dnsmasq.conf` and restart:

```bash
docker-compose restart dnsmasq
```

## Testing

From within the services network:

```bash
# Test from a container
docker exec -it navidrome nslookup navidrome.home 10.0.0.254

# Check dnsmasq logs
docker logs dnsmasq
```

From your device connected to WARP:

```bash
nslookup navidrome.home
# Should resolve to 10.0.0.5
```

## Troubleshooting

- **DNS not resolving**: Check that dnsmasq is running (`docker ps`) and Cloudflare Gateway policy is active
- **Timeout on requests**: Ensure firewall allows UDP 53 from WARP clients (already configured)
- **Services not found**: Verify the IP address in `dnsmasq.conf` matches `ipv4_address` in service docker-compose files
- **Permission denied errors**: Ensure `dnsmasq.conf` has readable permissions and SELinux is disabled for the container
