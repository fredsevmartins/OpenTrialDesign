"""Prepare a locally verified release without GitHub Actions.

Requires R/dependencies, Pandoc, LaTeX for the PDF browser check, Playwright,
Chromium and axe-core 4.10.3. It tests a clean archived source snapshot and an
isolated primary-package installation; dependencies come from the installed
libraries and must match the lockfile. This does not claim a clean OS restore.
It never uploads assets or changes repository/account settings.
"""
import argparse,csv,hashlib,io,json,os,platform,re,shutil,socket,subprocess,sys,tarfile,time,urllib.request,zipfile
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--output',required=True,type=Path)
p.add_argument('--axe-core',required=True,type=Path)
p.add_argument('--chromium',default=None)
a=p.parse_args();root=Path(__file__).resolve().parents[1]
out=a.output.resolve();axe=a.axe_core.resolve()
if out.exists():raise SystemExit('Use a new output directory to preserve earlier evidence.')
if '4.10.3' not in axe.read_text()[:2000]:raise SystemExit('Use axe-core 4.10.3 for the recorded browser audit.')
if subprocess.check_output(['git','status','--porcelain'],cwd=root,text=True).strip():
 raise SystemExit('Commit changes before preparing a release snapshot.')
sha=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
# Preserve the linkage to the already executed scientific-core baseline.
for line in (root/'validation/method-SHA256SUMS').read_text().splitlines():
 digest,name=line.split('  ',1)
 if hashlib.sha256((root/name).read_bytes()).hexdigest()!=digest:raise SystemExit('Baseline integrity mismatch: '+name)
archive=subprocess.check_output(['git','archive',sha],cwd=root)
out.mkdir(parents=True);work=out/'_work';source=work/'source';source.mkdir(parents=True)
with tarfile.open(fileobj=io.BytesIO(archive),mode='r:') as t:t.extractall(source,filter='data')
version=re.search(r'^Version: (.+)$',(source/'DESCRIPTION').read_text(),re.M)[1]
lib=work/'library';lib.mkdir()
env=os.environ.copy();env['R_LIBS']=str(lib)+(os.pathsep+env['R_LIBS'] if env.get('R_LIBS') else '')
logs=work/'logs';logs.mkdir()
def run(label,cmd,cwd=source,extra=None):
 print(label,flush=True)
 e=env.copy();e.update(extra or {})
 with (logs/(label+'.txt')).open('w') as f:
  subprocess.run(cmd,cwd=cwd,env=e,stdout=f,stderr=subprocess.STDOUT,check=True)
run('dependency-versions',['Rscript','-e',
 'p<-jsonlite::fromJSON("renv.lock",simplifyVector=FALSE)$Packages; i<-installed.packages(); expected<-vapply(p,function(x)x$Version,character(1)); observed<-i[names(p),"Version"]; print(data.frame(package=names(p),expected,observed));stopifnot(all(expected==observed));print(sessionInfo())'])
run('build',['R','CMD','build','.'])
tar=source/('OpenTrialDesign_'+version+'.tar.gz')
run('install',['R','CMD','INSTALL','--install-tests','-l',str(lib),str(tar)])
run('check',['R','CMD','check',str(tar)])
checklog=source/'OpenTrialDesign.Rcheck/00check.log'
if 'Status: OK' not in checklog.read_text():raise SystemExit('R CMD check did not finish with Status: OK')
for name in ['run-examples','scientific-reference','product-scientific-reference','stress-validation','method-reference']:
 run(name,['Rscript','scripts/'+name+'.R'])
# Isolated worker app and actual browser/PDF acceptance.
with socket.socket() as sock:sock.bind(('127.0.0.1',0));port=sock.getsockname()[1]
app_log=(logs/'app.txt').open('w')
app=subprocess.Popen(['Rscript','-e',f'options(OpenTrialDesign.max_jobs=2);OpenTrialDesign::run_app(host="127.0.0.1",port={port},launch.browser=FALSE)'],cwd=source,env=env,stdout=app_log,stderr=subprocess.STDOUT)
url=f'http://127.0.0.1:{port}/'
try:
 for attempt in range(120):
  if app.poll() is not None:raise RuntimeError('Application exited before browser acceptance.')
  try:
   with urllib.request.urlopen(url,timeout=1) as response:
    if response.status==200:break
  except (OSError,TimeoutError):time.sleep(.5)
 else:raise RuntimeError('Application did not become ready.')
 extra={'OTD_APP_URL':url,'OTD_TEST_PDF':'1','AXE_CORE_PATH':str(axe)}
 if a.chromium:extra['CHROMIUM_PATH']=a.chromium
 for name in ['product-browser','improvements-browser','method-browser']:
  run(name,[sys.executable,'scripts/'+name+'.py'],extra=extra)
finally:
 app.terminate()
 try:app.wait(timeout=10)
 except subprocess.TimeoutExpired:app.kill();app.wait()
 app_log.close()
run('documentation',['Rscript','-e','pkgdown::build_site(new_process=FALSE,install=FALSE)'])
shutil.copy2(tar,out/tar.name);shutil.copy2(source/'renv.lock',out/'renv.lock')
with zipfile.ZipFile(out/'OpenTrialDesign-documentation.zip','w',zipfile.ZIP_DEFLATED) as z:
 for file in sorted((source/'docs/site').rglob('*')):
  if file.is_file():z.write(file,file.relative_to(source/'docs/site'))
# Only evidence produced/read by this snapshot is included; historical files remain labelled.
with zipfile.ZipFile(out/'local-validation-evidence.zip','w',zipfile.ZIP_DEFLATED) as z:
 for file in sorted(logs.rglob('*')):
  if file.is_file():z.write(file,Path('logs')/file.relative_to(logs))
 for file in sorted((source/'OpenTrialDesign.Rcheck').rglob('*')):
  if file.is_file():z.write(file,Path('R-CMD-check')/file.relative_to(source/'OpenTrialDesign.Rcheck'))
 included=set()
 for pattern in ['*reference*.csv','*session*.txt','stress-*.txt','stress-*.csv','*browser.json','*accessibility*.json','accessibility-audit.json']:
  for file in sorted((source/'validation').glob(pattern)):
   if file.is_file() and file not in included:
    included.add(file);z.write(file,Path('validation')/file.name)
if not (source/'validation/method-ci-account-blocker.txt').is_file():raise RuntimeError('Missing original CI blocker record')
rout=(source/'OpenTrialDesign.Rcheck/tests/testthat.Rout').read_text(errors='replace')
matches=re.findall(r'\[\s*FAIL\s+(\d+)\s*\|\s*WARN\s+(\d+)\s*\|\s*SKIP\s+(\d+)\s*\|\s*PASS\s+(\d+)\s*\]',rout)
if not matches:raise RuntimeError('No executed test counts found in R CMD check log')
counts=tuple(map(int,matches[-1]))
if counts[:3]!=(0,0,0) or counts[3]<1:raise RuntimeError('Installed test evidence is not entirely passing')
summary={'version':version,'source_commit':sha,'verification':'local execution; hosted CI not executed',
 'platform':platform.platform(),'dependency_versions':'all locked installed versions matched; not a clean-OS restore',
 'r_cmd_check':'Status: OK','unit_tests':{'fail':counts[0],'warn':counts[1],'skip':counts[2],'pass':counts[3]},'browser_workflows':{},'scientific_reference_rows':{},
 'not_verified':['Windows','macOS','clean-container execution','new published container image','independent scientific qualification']}
for file in ['product-browser.json','improvements-browser.json','method-browser.json']:
 data=json.loads((source/'validation'/file).read_text());checks=data['checks']
 if not all(x['passed'] for x in checks) or data['javascript_errors']:raise RuntimeError('Browser evidence failed')
 summary['browser_workflows'][file]=len(checks)
for file in ['scientific-reference.csv','product-scientific-reference.csv','method-reference.csv']:
 rows=list(csv.DictReader((source/'validation'/file).open()))
 if not rows or not all(r['passed']=='TRUE' for r in rows):raise RuntimeError('Reference evidence failed')
 summary['scientific_reference_rows'][file]=len(rows)
(out/'verification.json').write_text(json.dumps(summary,indent=2)+'\n')
(out/'README-local-validation.txt').write_text('Locally verified OpenTrialDesign '+version+' prerelease.\nSource commit: '+sha+'\nHosted CI could not start due to the recorded account billing/spending limit.\nThe user authorized this local-validation release. No Windows, macOS or clean-container pass is claimed.\nNo new container image is published; do not relabel the previous 0.3.0 image as 0.4.0.\nSee verification.json and local-validation-evidence.zip for actual logs and limits.\nComputational checks do not confer independent scientific or regulatory qualification.\n')
files=sorted(f for f in out.iterdir() if f.is_file())
(out/'SHA256SUMS').write_text(''.join(hashlib.sha256(f.read_bytes()).hexdigest()+'  '+f.name+'\n' for f in files))
print(json.dumps(summary,indent=2));print('Artifacts ready in '+str(out),flush=True)
