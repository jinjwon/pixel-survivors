"""Pinned upstream data and sprites for a private fan prototype, not IP clearance."""
import csv,io,json,hashlib,pathlib,urllib.request,concurrent.futures,time
ROOT=pathlib.Path(__file__).resolve().parents[1]
def get(url):
 for attempt in range(4):
  try:
   with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'MeadowLocalPrototype'}),timeout=45) as r:return r.read()
  except Exception:
   if attempt==3: raise
   time.sleep(1+attempt)
def sha(b):return hashlib.sha256(b).hexdigest()
m=json.loads((ROOT/'assets/manifest.json').read_text())
data_commit=json.loads(get('https://api.github.com/repos/PokeAPI/pokeapi/commits/master'))['sha']
base=f'https://raw.githubusercontent.com/PokeAPI/pokeapi/{data_commit}/data/v2/csv/'
sources=[]
def table(name):
 b=get(base+name+'.csv'); sources.append({'url':base+name+'.csv','sha256':sha(b)})
 return list(csv.DictReader(io.StringIO(b.decode())))
names={int(x['pokemon_species_id']):x['name'] for x in table('pokemon_species_names') if x['local_language_id']=='3'}
species={int(x['id']):x for x in table('pokemon_species') if int(x['id'])<=386}
types={int(x['id']):x['identifier'] for x in table('types')}
pt={}
for x in table('pokemon_types'):
 n=int(x['pokemon_id'])
 if n<=386:pt.setdefault(n,[]).append((int(x['slot']),types[int(x['type_id'])]))
# Historical types restore pre-Fairy identities (Gen III rules).
for x in table('pokemon_types_past'):
 n=int(x['pokemon_id'])
 if n<=386 and int(x['generation_id'])==5:
  if not isinstance(pt.get(n),dict):pt[n]={}
  pt[n][int(x['slot'])]=types[int(x['type_id'])]
stats={}
for x in table('pokemon_stats'):
 n=int(x['pokemon_id'])
 if n<=386:stats.setdefault(n,{})[int(x['stat_id'])]=int(x['base_stat'])
roster=[]
for n,s in species.items():
 ts=pt[n]; ts=[v for _,v in sorted(ts.items() if isinstance(ts,dict) else ts)]
 children=sorted(k for k,v in species.items() if v['evolves_from_species_id']==str(n))
 roster.append({'id':n,'name':names[n],'slug':s['identifier'],'generation':int(s['generation_id']),'types':ts,'children':children,'stats':stats[n]})
(ROOT/'assets/data/roster.json').write_text(json.dumps(roster,ensure_ascii=False,separators=(',',':'))+'\n')
(ROOT/'docs/POKEAPI-DATA-LICENSE.md').write_bytes(get(f'https://raw.githubusercontent.com/PokeAPI/pokeapi/{data_commit}/LICENSE.md'))
(ROOT/'assets/data/sources.json').write_text(json.dumps({'commit':data_commit,'csv':sources,'adaptation':'Gen III historical types; custom survival move loadouts, evolution levels and balancing.'},indent=2)+'\n')
existing={f['file']:f for f in m['files']}
def sprite(n):
 p=f'assets/pokemon/{n}.png'; url=f'https://raw.githubusercontent.com/PokeAPI/sprites/{m["commit"]}/sprites/pokemon/{n}.png'
 data=(ROOT/p).read_bytes() if p in existing else get(url)
 assert data[:8]==b'\x89PNG\r\n\x1a\n'
 (ROOT/p).write_bytes(data)
 return {'file':p,'source':url,'sha256':sha(data),'bytes':len(data),'attribution':'Image copyright The Pokemon Company, per upstream LICENCE.txt'}
with concurrent.futures.ThreadPoolExecutor(max_workers=8) as ex: m['files']=list(ex.map(sprite,range(1,387)))
(ROOT/'assets/manifest.json').write_text(json.dumps(m,indent=2)+'\n')
fontbase='https://raw.githubusercontent.com/orioncactus/pretendard/v1.3.9/'
fontfiles=[]
for weight in ['Regular','SemiBold','Bold']:
 url=fontbase+f'packages/pretendard/dist/public/static/Pretendard-{weight}.otf'
 b=get(url)
 p=f'assets/fonts/Pretendard-{weight}.otf';(ROOT/p).write_bytes(b)
 fontfiles.append({'file':p,'source':url,'sha256':sha(b)})
(ROOT/'assets/fonts/OFL.txt').write_bytes(get(fontbase+'LICENSE'))
(ROOT/'assets/fonts/manifest.json').write_text(json.dumps(fontfiles,indent=2)+'\n')
print('READY:',len(roster),'species,',len(m['files']),'sprites, 3 Pretendard weights',flush=True)
