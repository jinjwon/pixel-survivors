"""Small pinned asset selection; not a representation of IP clearance."""
import hashlib,json,pathlib,urllib.request
root=pathlib.Path(__file__).resolve().parents[1]
def get(url):
 with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'LocalMeadowPrototype/0.1'}),timeout=30) as r:return r.read()
commit=json.loads(get('https://api.github.com/repos/PokeAPI/sprites/commits/master'))['sha']
base=f'https://raw.githubusercontent.com/PokeAPI/sprites/{commit}'
m={'repository':'https://github.com/PokeAPI/sprites','commit':commit,'rights_status':'Original Pokemon IP permission unresolved. Local prototype; not cleared for redistribution.','files':[]}
for n in [1,2,3,4,5,6,7,8,9,10,16,25,43,54,94]:
 url=base+f'/sprites/pokemon/{n}.png';data=get(url)
 assert data[:8]==b'\x89PNG\r\n\x1a\n'
 p=f'assets/pokemon/{n}.png';(root/p).write_bytes(data)
 m['files'].append({'file':p,'source':url,'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data),'attribution':'Image copyright: The Pokemon Company, per upstream LICENCE.txt'})
(root/'docs/POKEAPI-LICENCE.txt').write_bytes(get(base+'/LICENCE.txt'))
(root/'assets/manifest.json').write_text(json.dumps(m,indent=2)+'\n')
print('Fetched',len(m['files']),'sprites;',sum(x['bytes'] for x in m['files']),'bytes; commit',commit)
