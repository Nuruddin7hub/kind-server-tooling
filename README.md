# kind-server-tooling

Utility scripts for administering my always-on home server ("KS", an old
ASUS VivoBook running Ubuntu Server on my Tailscale network).

## Contents

- `ks.sh` — one-command SSH into the server (key auth)
- `ks-audit*.sh` — remote audit helpers
- `ks-act-playbook.md` — my operations playbook

## Setup

Replace `<KS_TAILSCALE_IP>` with your server's Tailscale IP and
`<YOUR_EGRESS_PROXY:PORT>` with your egress proxy. Uses key-only SSH auth.
