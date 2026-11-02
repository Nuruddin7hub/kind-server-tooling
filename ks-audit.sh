#!/bin/bash
# read-only KS audit
ks() {
  ssh -o UserKnownHostsFile=~/.ssh/known_hosts -o ProxyCommand="nc -X connect -x <YOUR_EGRESS_PROXY:PORT> %h %p" -i ~/.ssh/id_ed25519 kind@<KS_TAILSCALE_IP> "$1"
}
echo "LOCAL_MY_TIME: $(TZ=Asia/Kuala_Lumpur date '+%Y-%m-%d %H:%M:%S %Z')"
echo "=== free/uptime/gateway/disk ==="
ks 'date "+%Y-%m-%d %H:%M:%S %Z"; free -h; echo ---; uptime; echo ---; systemctl --user is-active openclaw-gateway; echo ---; df -h /home/kind /home/kind/.openclaw 2>&1; echo ---; du -sh ~/.openclaw 2>&1'
echo "=== ps top mem ==="
ks 'ps aux --sort=-%mem | head -25'
echo "=== browser procs ==="
ks 'ps aux | grep -i -E "chrom|playwright|headless" | grep -v grep || echo NO_BROWSER_PROCESS_FOUND'
echo "=== gateway proc ==="
ks 'ps aux | grep -i openclaw | grep -v grep | head -20'
