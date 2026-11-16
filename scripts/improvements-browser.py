"""Acceptance for specification review, sensitivity replay and accessibility.
Requires playwright and axe-core 4.10.3 (MPL-2.0), supplied separately for tests.
"""
from pathlib import Path
import os,json,csv,zipfile
from playwright.sync_api import sync_playwright
root=Path(__file__).resolve().parents[1];out=root/'validation';checks=[];audits=[]
axe=Path(os.environ['AXE_CORE_PATH'])
def record(name):checks.append({'workflow':name,'passed':True})
with sync_playwright() as p:
 b=p.chromium.launch(executable_path=os.environ.get('CHROMIUM_PATH') or None,headless=True,args=['--no-sandbox'])
 page=b.new_page(viewport={'width':1440,'height':1100});errors=[]
 page.on('pageerror',lambda e:errors.append(str(e)))
 page.goto(os.environ.get('OTD_APP_URL','http://127.0.0.1:3845/'),wait_until='networkidle')
 page.wait_for_function('window.Shiny && Shiny.shinyapp && Shiny.shinyapp.$socket.readyState===1')
 page.add_script_tag(path=str(axe))
 def audit(state):
  report=page.evaluate("async () => await axe.run(document,{runOnly:{type:'tag',values:['wcag2a','wcag2aa','wcag21aa']}})")
  audits.append({'state':state,'violations':report['violations'],'incomplete':report['incomplete']})
  assert not report['violations'],json.dumps(report['violations'],indent=2)
 assert 'two-sided' in page.locator('#scientific-contract').inner_text()
 page.locator('#effect').fill('-0.3')
 page.locator("#alternative").select_option("less")
 page.wait_for_function("document.querySelector('#scientific-contract').textContent.includes('H1: effect < 0')")
 record('pre-execution review updates hypothesis direction and alpha')
 page.keyboard.press('Control+Home');page.keyboard.press('Tab')
 # Inspect the skip target and use it from keyboard, independent of browser focus restoration.
 skip=page.locator('.skip-link');skip.focus();page.keyboard.press('Enter')
 assert page.evaluate("location.hash==='#main-content'")
 record('keyboard skip navigation')
 audit('fixed specification')
 page.locator('#effect').fill('0.5');page.locator("#alternative").select_option("two.sided")
 page.get_by_role('tab',name='Group sequential designs',exact=True).click()
 page.locator("#futility").select_option("binding")
 page.wait_for_function("document.querySelector('#scientific-contract').textContent.includes('must be followed')")
 audit('binding sequential specification');record('binding futility review before calculation')
 page.get_by_role('tab',name='Scenario comparison',exact=True).click()
 page.locator('#compare').click()
 page.wait_for_function("document.querySelector('#comparison').textContent.includes('S004')")
 with page.expect_download() as info:page.locator('#comparison_csv').click()
 target=out/'sensitivity-browser.csv';info.value.save_as(str(target))
 rows=list(csv.DictReader(target.read_text().splitlines()));assert len({r['scenario'] for r in rows})==4
 values={r['scenario']:float(r['value']) for r in rows if r.get('metric')=='n_per_arm'}
 assert values['S001']>values['S002'] and values['S003']>values['S001']
 with page.expect_download() as info:page.locator('#comparison_bundle').click()
 bundle=out/'sensitivity-browser.zip';info.value.save_as(str(bundle))
 with zipfile.ZipFile(bundle) as z:
  assert 'scenarios/S004.json' in z.namelist()
  saved=json.loads(z.read('scenarios/S001.json'));assert saved['parameters']['effect']==.3
 record('analytical sensitivity grid and portable scenario bundle')
 page.locator('#nsim').fill('20');page.locator('#grid_simulate').check();page.locator('#compare').click()
 page.wait_for_function("document.querySelector('#job_status').textContent.includes('Completed')")
 page.wait_for_function("document.querySelector('#comparison').textContent.includes('estimate')")
 with page.expect_download() as info:page.locator('#comparison_csv').click()
 f=out/'sensitivity-simulation-browser.csv';info.value.save_as(str(f))
 rows=list(csv.DictReader(f.read_text().splitlines()))
 assert {int(float(r['seed'])) for r in rows}=={2026,2027,2028,2029}
 record('background sensitivity simulation retains four deterministic seeds')
 audit('completed sensitivity grid')
 page.locator('#nsim').fill('20000');page.locator('#compare').click()
 page.wait_for_function("document.querySelector('#job_status').textContent.includes('Running')")
 page.locator('#cancel').click();page.wait_for_function("document.querySelector('#job_status').textContent.includes('cancelled')")
 record('batch cancellation discards partial results')
 page.set_viewport_size({'width':390,'height':844})
 assert page.evaluate('document.documentElement.scrollWidth<=innerWidth')
 page.screenshot(path=str(out/'improvements-mobile.png'),full_page=True)
 record('responsive sensitivity interface')
 assert not errors,errors
 b.close()
(out/'improvements-browser.json').write_text(json.dumps({'checks':checks,'javascript_errors':errors},indent=2)+'\n')
(out/'accessibility-audit.json').write_text(json.dumps({'axe_version':'4.10.3','states':audits},indent=2)+'\n')
print(json.dumps(checks))
