"""Add only the four missing evolution sprites from the already pinned source."""
import hashlib,json,pathlib,urllib.request
root=pathlib.Path(__file__).resolve().parents[1]
path=root/'assets/manifest.json'
m=json.loads(path.read_text())
existing={x['file']:x for x in m['files']}
for number in (2,3,8,9):
 relative=f'assets/pokemon/{number}.png'
 url=f'https://raw.githubusercontent.com/PokeAPI/sprites/{m["commit"]}/sprites/pokemon/{number}.png'
 with urllib.request.urlopen(url,timeout=30) as response:data=response.read()
 assert data.startswith(b'\x89PNG\r\n\x1a\n')
 (root/relative).write_bytes(data)
 existing[relative]={'file':relative,'source':url,'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data),'attribution':'Image copyright: The Pokemon Company, per upstream LICENCE.txt'}
m['files']=sorted(existing.values(),key=lambda entry:int(pathlib.Path(entry['file']).stem))
path.write_text(json.dumps(m,indent=2)+'\n')
print('Recorded',len(m['files']),'sprites at pinned commit',m['commit'])
