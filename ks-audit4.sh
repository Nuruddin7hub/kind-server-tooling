#!/bin/bash
ks() {
  ssh -o UserKnownHostsFile=~/.ssh/known_hosts -o ProxyCommand="nc -X connect -x <YOUR_EGRESS_PROXY:PORT> %h %p" -i ~/.ssh/id_ed25519 kind@<KS_TAILSCALE_IP> "$1"
}
ks 'openclaw config schema > /tmp/ks-schema.txt 2>&1; wc -l /tmp/ks-schema.txt; grep -n embedding /tmp/ks-schema.txt | head -40; echo ---SEARCHPROVIDER---; grep -n search /tmp/ks-schema.txt | head -60'
echo "=== schema memory block ==="
ks 'sed -n "5930,6000p" /tmp/ks-schema.txt'
echo "=== defaults model ==="
ks 'python3 -c "
import json
d=json.load(open(\"/home/kind/.openclaw/openclaw.json\"))
print(\"defaults:\", d.get(\"agents\",{}).get(\"defaults\",{}))
print(\"main keys:\", list(d[\"agents\"][\"entries\"][\"main\"].keys()))
"'
echo "=== current free ==="
ks 'date "+%Y-%m-%d %H:%M:%S %Z"; free -h; ps aux --sort=-%mem | head -6 | cut -c1-160'
