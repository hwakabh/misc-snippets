import os
import json
import requests


DEELP_TRANSLATE_URL = 'https://api.deepl.com/v2/translate'

print('>>> Fetching API keys to use DeepL API ...')
DEEPL_API_KEY = os.environ.get('DEEPL_API_KEY', None)
if DEEPL_API_KEY is None:
    print('DEEPL_API_KEY not provides, please set environmental variable with your shell.')

srctext = '''
こんにちは、私の名前はロバートです。DeepL の API を試しています。
'''

print('>>> Source text:')
print(srctext)

print('>>> Starting translate with DeepL ...\n')

h = {'Content-Type': 'application/x-www-form-urlencoded'}
body = {
  'auth_key': DEEPL_API_KEY,
  'text': srctext,
  # 'source_lang': '',
  'target_lang': 'EN',
}
res = requests.post(url=DEELP_TRANSLATE_URL, headers=h, data=body)

print('>>> Translated text:')
trstext = json.loads(res.text)
for t in trstext.get('translations', None):
    print(t.get('text', None))