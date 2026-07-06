#!/bin/bash
# Update firewalld configuration from ~/.config/firewalld
# Copies zones and policies to system directories and reloads

set -e

echo "🔥 Updating firewalld configuration..."

# Cleanup: Remove orphaned zones and policies
echo "🧹 Cleaning up orphaned configuration..."

# Remove zones not in config
for zone in $(sudo firewall-cmd --get-zones 2>/dev/null); do
  if [ ! -f ~/.config/firewalld/zones/$zone.xml ]; then
    sudo firewall-cmd --permanent --delete-zone=$zone 2>/dev/null && echo "  Removed zone: $zone" || true
  fi
done

# Remove policies not in config
for policy in $(sudo firewall-cmd --get-policies 2>/dev/null); do
  if [ ! -f ~/.config/firewalld/policies/$policy.xml ]; then
    sudo firewall-cmd --permanent --delete-policy=$policy 2>/dev/null && echo "  Removed policy: $policy" || true
  fi
done

# Flush and recopy files
echo "🧹 Flushing existing firewall configuration..."
sudo rm -f /etc/firewalld/zones/*.xml /etc/firewalld/policies/*.xml

# Copy zones
if ls ~/.config/firewalld/zones/*.xml 1>/dev/null 2>&1; then
    echo "📁 Copying zones..."
    sudo cp ~/.config/firewalld/zones/*.xml /etc/firewalld/zones/
fi

# Copy policies
if ls ~/.config/firewalld/policies/*.xml 1>/dev/null 2>&1; then
    echo "📁 Copying policies..."
    sudo mkdir -p /etc/firewalld/policies
    sudo cp ~/.config/firewalld/policies/*.xml /etc/firewalld/policies/
fi

# Reload
echo "🔄 Reloading firewall..."
sudo firewall-cmd --reload

echo ""
echo "✅ Firewall updated!"
echo ""
echo "Active configuration:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔵 Zones:"
sudo firewall-cmd --get-active-zones | grep -E "^[a-z]|interfaces:"
echo ""
echo "📋 Policies:"
sudo firewall-cmd --policy=public-to-docker --list-all 2>/dev/null | grep -E "ingress|egress|rule"
