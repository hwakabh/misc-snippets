import os
import sys
import json
import requests


DEELP_TRANSLATE_URL = 'https://api.deepl.com/v2/translate'

print('>>> Fetching API keys to use DeepL API ...\n')
DEEPL_API_KEY = os.environ.get('DEEPL_API_KEY', None)
if DEEPL_API_KEY is None:
    print('DEEPL_API_KEY not provides, please set environmental variable with your shell.')
    sys.exit(1)


with open('./in_text/out_random_100.input.min') as f:
    lines = f.readlines()

print('>>> Number of publications: {}\n'.format(len(lines)))

for l in lines:
    print('>>> ------------')
    hsh = l.split('***')[0]
    link_url = l.split('***')[1]
    srctext = l.split('***')[2].replace('\\n', ' ').replace(' .', '')

    print(f'> Source URL: {link_url}')
    print(f'> Glocalist URL: https://glocalist.asia/publications/#/{hsh}')
    print('> Source text:')
    print(srctext)

    print('> Starting translate with DeepL ...\n')

    h = {'Content-Type': 'application/x-www-form-urlencoded'}
    body = {
      'auth_key': DEEPL_API_KEY,
      'text': srctext,
      'source_lang': 'EN',
      'target_lang': 'JA',
    }
    res = requests.post(url=DEELP_TRANSLATE_URL, headers=h, data=body)

    print('> Translated text:')
    trstext = json.loads(res.text)
    for t in trstext.get('translations', None):
        print(t.get('text', None))