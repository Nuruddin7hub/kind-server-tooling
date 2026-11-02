
## Browser Actions Playbook — Scroll, Click, Search, Type (2026-10-27, after a real failure)
Root cause found in Main Session 18:54: the agent called browserTool({action:"act", actions:[{kind:"scroll", deltaY:500}]}) three times. That call is WRONG and always fails with "Error: request required" (bridge, internal_error). There is NO "scroll" act kind, and "act" does NOT take an "actions" array for a plain scroll. The agent then falsely told the user it had scrolled. Never do that again.

Correct browser-tool shapes (via the exec catalog browser tool):
- Navigate: browserTool({action:"navigate", targetUrl:"https://..."})
- Snapshot: browserTool({action:"snapshot"}) — NO depth limit. A depth-limited snapshot (for example depth:3) truncates YouTube before the video links and returns 0 refs. If a snapshot returns 0 refs, wait and snapshot again — do not click blindly.
- Scroll: there is NO scroll kind. Scroll ONLY with evaluate:
  browserTool({action:"act", kind:"evaluate", fn:"() => { window.scrollTo(0, 1500); return window.scrollY; }"})
  or window.scrollBy(0, 800). Then re-snapshot. Never use kind:"scroll", never use actions:[...] for a plain scroll.
- Click a link: browserTool({action:"act", kind:"click", ref:"<FRESH ref>"})
- Click by coordinates (panel Interact mode uses this path): first get coordinates with evaluate getBoundingClientRect, then browserTool({action:"act", kind:"clickCoords", x:<n>, y:<n>})
- Type into a field: browserTool({action:"act", kind:"type", ref:"<ref>", text:"...", submit:true})
- Wait: browserTool({action:"act", kind:"wait", timeMs:3000})
- Scroll an element into view: browserTool({action:"act", kind:"scrollIntoView", ref:"<ref>"})

Rules, in order, every time:
1. Snapshot FIRST, and always use FRESH refs from the latest snapshot. Refs die when the page re-renders — YouTube re-renders constantly. Never reuse a ref from an older snapshot.
2. Click the TITLE link, not the thumbnail. On YouTube, video titles are links with /watch?v=... URLs; thumbnails are often aria-hidden or a different element. If the title link has no ref, use its URL directly (rule 5).
3. After navigate, WAIT 3-5 seconds (act wait), then snapshot with no depth limit. If refs are still 0, snapshot once more after another wait. The YouTube feed takes time to render in headless mode.
4. After any click, WAIT, then re-snapshot and report the NEW tab title and URL from that snapshot. Never report success without a confirming snapshot.
5. If a ref click fails ONCE, re-snapshot and try the NEW ref. If it fails TWICE, stop clicking refs and navigate DIRECTLY to the URL from the snapshot, for example a https://www.youtube.com/watch?v=... URL — that URL navigation is proven to work on KS.
6. NEVER retry the same failed operation more than twice, and NEVER retry a failed shape (for example kind:"scroll" or an actions array) at all — change the shape to the correct one above on the first failure.
7. For search, if the search box is awkward, navigate directly to the site search URL instead: YouTube https://www.youtube.com/results?search_query=<query>, Wikipedia https://en.wikipedia.org/w/index.php?search=<query> — then snapshot and click a result by its fresh title ref, or by direct URL.
8. NEVER tell the user you scrolled, clicked, or opened something you did not confirm by snapshot. If you failed, say plainly what failed, what error you got, and what you tried next.
9. When the user asks to WATCH: keep the browser running, do NOT stop it at the end of the turn, and tell the user to use the side-panel Browser tab (Interact mode) in /chat/main. Panel taps are the own take-control of the user; agent clicks are separate and use refs and coords above. When the user only asks for information, browser-stopped idle is still fine because the agent autostarts it.
