from playwright.sync_api import sync_playwright
from pathlib import Path
import json
import os
import shutil
ROOT = Path(__file__).resolve().parents[1]
results=[]
with sync_playwright() as p:
 browser=p.chromium.launch(executable_path=os.environ.get('CHROMIUM_PATH', shutil.which('chromium') or '/usr/bin/chromium'),headless=True,args=['--no-sandbox'])
 page=browser.new_page(viewport={'width':1440,'height':1100})
 errors=[]
 page.on('pageerror',lambda e: errors.append(str(e)))
 page.goto(os.environ.get('OTD_APP_URL', 'http://127.0.0.1:3838/'),wait_until='networkidle')
 page.wait_for_function("window.Shiny && Shiny.shinyapp && Shiny.shinyapp.$socket && Shiny.shinyapp.$socket.readyState === 1")
 page.locator('#effect').fill('0.5')
 page.locator('#calculate').click()
 page.get_by_role('tab',name='Sample size and power',exact=True).click()
 page.wait_for_function("document.querySelector('#fixed').textContent.includes('64')")
 results.append({'workflow':'fixed sample size','passed':True})
 page.get_by_role('tab',name='Group sequential designs',exact=True).click()
 page.locator('#sequential').click()
 page.wait_for_function("document.querySelector('#sequential_result').textContent.includes('group sequential design')")
 results.append({'workflow':'sequential design','passed':True})
 page.locator('#nsim').fill('20')
 page.get_by_role('tab',name='Adaptive designs',exact=True).click()
 page.locator('#adaptive').click()
 page.wait_for_function("document.querySelector('#adaptive_result').textContent.includes('equality null')")
 results.append({'workflow':'adaptive simulation','passed':True})
 page.get_by_role('tab',name='Survival studies',exact=True).click()
 page.locator('#survival').click()
 page.wait_for_function("document.querySelector('#survival_result').textContent.includes('Schoenfeld')")
 results.append({'workflow':'survival planning','passed':True})
 page.get_by_role('tab',name='Scientific reporting',exact=True).click()
 with page.expect_download() as info: page.locator('#report').click()
 download=info.value
 path=str(ROOT/'validation/browser-download.html')
 download.save_as(path)
 assert 'Methodological provenance' in Path(path).read_text()
 results.append({'workflow':'HTML report download','passed':True})
 page.get_by_role('tab',name='Group sequential designs',exact=True).click()
 page.screenshot(path=str(ROOT/'validation/shiny-browser.png'),full_page=True)
 assert not errors, errors
 browser.close()
(ROOT/'validation/browser-smoke.json').write_text(json.dumps({'results':results,'javascript_errors':errors},indent=2)+'\n')
print(json.dumps(results))
