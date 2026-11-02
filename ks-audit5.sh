#!/bin/bash
ks() {
  ssh -o UserKnownHostsFile=~/.ssh/known_hosts -o ProxyCommand="nc -X connect -x <YOUR_EGRESS_PROXY:PORT> %h %p" -i ~/.ssh/id_ed25519 kind@<KS_TAILSCALE_IP> "$1"
}
ks 'sed -n "47179,47560p" /tmp/ks-schema.txt'
