#!/bin/bash
ks() {
  ssh -o UserKnownHostsFile=~/.ssh/known_hosts -o ProxyCommand="nc -X connect -x <YOUR_EGRESS_PROXY:PORT> %h %p" -i ~/.ssh/id_ed25519 kind@<KS_TAILSCALE_IP> "$1"
}
echo "=== logs counts (full 1000) ==="
ks 'openclaw logs --limit 1000 --plain --timeout 30000 2>&1 | tee /tmp/ks-logs.txt | grep -c -i "gemini embeddings failed"; echo "---deleted---"; grep -c "bound service account is deleted or disabled" /tmp/ks-logs.txt; echo "---401 total---"; grep -c "401" /tmp/ks-logs.txt; echo "---first/last lines timestamps---"; head -5 /tmp/ks-logs.txt; echo ...; tail -5 /tmp/ks-logs.txt; echo "---sample 401 lines (scrubbed, no keys)---"; grep -i "gemini embeddings failed" /tmp/ks-logs.txt | head -5 | cut -c1-300'
echo "=== logs time window ==="
ks 'grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}" /tmp/ks-logs.txt | sort | uniq -c | head -30; echo ---; wc -l /tmp/ks-logs.txt'
echo "=== config memory provider ONLY (redacted) ==="
ks 'python3 -c "
import json,sys
try:
  d=json.load(open(\"/home/kind/.openclaw/openclaw.json\"))
except Exception as e:
  print(\"JSON_LOAD_FAIL\",e); sys.exit(0)
def walk(o,path=\"\"):
  if isinstance(o,dict):
    for k,v in o.items():
      lk=k.lower()
      if any(s in lk for s in [\"key\",\"token\",\"secret\",\"password\",\"auth\"]):
        continue
      if any(s in lk for s in [\"memory\",\"search\",\"embed\",\"provider\"]):
        print(path+\"/\"+k,\"=\",repr(v)[:300])
      walk(v,path+\"/\"+k)
  elif isinstance(o,list):
    for i,v in enumerate(o): walk(v,path+f\"[{i}]\")
walk(d)
print(\"TOP_KEYS:\",list(d.keys()) if isinstance(d,dict) else type(d))
agents=d.get(\"agents\",{}) if isinstance(d,dict) else {}
print(\"AGENTS_KEYS:\",list(agents.keys()) if isinstance(agents,dict) else agents)
main=agents.get(\"main\",{}) if isinstance(agents,dict) else {}
print(\"MAIN_KEYS:\",list(main.keys()) if isinstance(main,dict) else main)
print(\"MAIN_MEMORY_RAW_REDACTED:\",{k:(v if not any(s in k.lower() for s in [\"key\",\"token\",\"secret\"]) else \"<REDACTED>\") for k,v in main.get(\"memory\",{}).items()} if isinstance(main.get(\"memory\"),dict) else main.get(\"memory\"))
"'
echo "=== config schema ==="
ks 'openclaw config schema 2>&1 | tee /tmp/ks-schema.txt | grep -i -n -E "memory|search|embed" | head -60; echo "---schema lines---"; wc -l /tmp/ks-schema.txt; echo "---schema context around memory---"; grep -i -n -A3 -B3 "memory" /tmp/ks-schema.txt | head -120'
