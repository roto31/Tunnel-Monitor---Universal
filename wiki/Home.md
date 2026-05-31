# Universal VPN Monitor Wiki

Source for [GitHub Wiki](https://github.com/roto31/Tunnel-Monitor---Universal/wiki). Edit pages in [`.wiki-publish/`](../.wiki-publish/) and push to the wiki remote.

## Pages

See [.wiki-publish/Home.md](../.wiki-publish/Home.md) for the canonical wiki home.

Sync (regenerates all of `.wiki-publish/` from repo docs):

```bash
python3 scripts/sync-wiki-all.py
cd .wiki-publish && git add -A && git commit -m "Sync wiki from repo" && git push origin master
```
