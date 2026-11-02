#!/bin/bash
# SSH into KS (kind-server) via Tailscale through the egress proxy
exec ssh -i ~/.ssh/id_ed25519 \
  -o BatchMode=yes -o ConnectTimeout=20 \
  -o UserKnownHostsFile=~/.ssh/known_hosts \
  -o StrictHostKeyChecking=no \
  -o ProxyCommand="nc -X connect -x <YOUR_EGRESS_PROXY:PORT> %h %p" \
  kind@<KS_TAILSCALE_IP> "$@"
