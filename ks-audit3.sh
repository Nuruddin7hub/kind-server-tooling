#!/bin/bash
ks() {
  ssh -o UserKnownHostsFile=~/.ssh/known_hosts -o ProxyCommand="nc -X connect -x <YOUR_EGRESS_PROXY:PORT> %h %p" -i ~/.ssh/id_ed25519 kind@<KS_TAILSCALE_IP> "$1"
}
ks 'echo "---401 by UTC hour-minute window---";
grep "gemini embeddings failed" /tmp/ks-logs.txt | awk "{print substr(\$1,1,16)}" | sort | uniq -c | tail -40;
echo "---LAST HOUR 16:04-17:04 UTC count---";
grep "gemini embeddings failed" /tmp/ks-logs.txt | awk "{t=\$1; gsub(/[^0-9T:]/,\"\",t); if (t>=\"2026-10-28T16:04\" && t<=\"2026-10-28T17:04\") c++} END{print c+0}";
echo "---LAST HOUR all memory-sync-failed---";
grep "memory sync failed" /tmp/ks-logs.txt | awk "{t=\$1; if (t>=\"2026-10-28T16:04\" && t<=\"2026-10-28T17:04\") c++} END{print c+0}";
echo "---401 trigger kinds (last 1000)---";
grep "gemini embeddings failed" /tmp/ks-logs.txt | grep -oE "memory sync failed \([^)]+\)" | sort | uniq -c;
echo "---any non-warn/error tied to memory in last hour---";
grep "memory" /tmp/ks-logs.txt | awk "{t=\$1; if (t>=\"2026-10-28T16:04\") print}" | cut -c1-200 | head -40;
echo "---providers keys only---";
python3 -c "
import json
d=json.load(open(\"/home/kind/.openclaw/openclaw.json\"))
print(\"models.providers keys:\", list(d.get(\"models\",{}).get(\"providers\",{}).keys()))
print(\"models keys:\", list(d.get(\"models\",{}).keys()))
print(\"agents.entries keys:\", list(d.get(\"agents\",{}).get(\"entries\",{}).keys()))
m=d[\"agents\"][\"entries\"][\"main\"].get(\"memory\",{})
print(\"main.memory:\", m)
print(\"main.model:\", d[\"agents\"][\"entries\"][\"main\"].get(\"model\"))
"'
echo "---schema: memory-search block lines 5900-6100---";
sed -n "5900,6100p" /tmp/ks-schema.txt;
echo "---schema: any search.provider / embedding enum---";
grep -n -i "embedding" /tmp/ks-schema.txt | head -40;
grep -n "search" /tmp/ks-schema.txt | grep -i -E "provider|enum" | head -40;
grep -n "\"gemini\"" /tmp/ks-schema.txt | head -20;
grep -n "\"nvidia\"" /tmp/ks-schema.txt | head -20;'
