import json
import os
import sys

import requests

gh_username = 'hwakabh'
gh_reponame = 'waseda-mochida'

print('Fetching GitHub PAT from shell')
TOKEN = os.environ.get('TOKEN', None)
if TOKEN is None:
    print('  TOKEN not provides, please set environmental variable with your shell.')
    sys.exit(1)

url = f'https://api.github.com/repos/{gh_username}/{gh_reponame}/deployments'
header = {'authorization': 'token ' + TOKEN}

res = requests.get(url)
resjson = json.loads(res.text)
id_urls = [r['url'] for r in resjson]

if len(id_urls) != 0:
    print('Following Deployements would be deactivated')
    payload = {'state': 'inactive'}
    post_header = {
        'accept': 'application/vnd.github.ant-man-preview+json',
        'authorization': 'token ' + TOKEN
    }
    for i in id_urls:
        print(f'  {i}')
        requests.post(i + '/statuses', headers=post_header, json=payload)
        print('  Done')

    print('Deleting deployments')
    for i in id_urls:
        print(f'  Deleting deployment id = {i} ...')
        requests.delete(i, headers=header)
        print('  Done')

    print(f'Cleaned up all deployments in repo: {gh_reponame}')
else:
    print(f'No environment found in repo: {gh_reponame}')
