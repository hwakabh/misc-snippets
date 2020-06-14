import requests
import json
import os
import shutil
import tarfile
import urllib3
from urllib3.exceptions import InsecureRequestWarning
urllib3.disable_warnings(InsecureRequestWarning)


class VRli():
    def __init__(self, ipaddress, username, password, provider):
        self.ipaddress = ipaddress
        self.username = username
        self.password = password
        self.provider = provider
        self.headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
        }
        self.rest_port = 9543
        self.baseuri = 'https://{0}:{1}'.format(self.ipaddress, self.rest_port)

        self.set_token()

    def set_token(self):
        body = {
            'username': self.username,
            'password': self.password,
            'provider': self.provider
        }
        # POST to fetch token
        token = self.post(
            urlsuffix='/api/v1/sessions',
            headers=self.headers,
            reqbody=json.dumps(body)
        )
        # Update headers
        self.headers['Authorization'] = 'Bearer {}'.format(token.get('sessionId'))

    def get(self, urisuffix):
        uri = '{0}{1}'.format(self.baseuri, urisuffix)
        res = requests.get(uri, headers=self.headers, verify=False)
        return json.loads(res.text)

    def post(self, urlsuffix, headers=None, reqbody=None):
        uri = '{0}{1}'.format(self.baseuri, urlsuffix)
        res = requests.post(uri, auth=(self.username, self.password), headers=self.headers, data=reqbody, verify=False)
        return json.loads(res.text)

    # def dump_config_file(self, dump_filename='vrli_config.tmp'):
    #     uri = '{0}{1}'.format(self.baseuri, '/api/v1/config/data')
    #     res = requests.get(uri, headers=self.headers, verify=False, stream=True)

    #     # Download dumpfile via REST-API
    #     with open(dump_filename, 'wb') as f:
    #         shutil.copyfileobj(res.raw, f)
    #     del res

    #     # Extract and remove originals
    #     with tarfile.open(dump_filename, 'r') as tar:
    #         for tarinfo in tar:
    #             if tarinfo.isreg():
    #                 raw_data = b''.join(tar.extractfile(tarinfo).readlines())

    #     # Cleanup
    #     if os.path.exists(dump_filename):
    #         os.remove(dump_filename)

    #     return json.loads(raw_data.decode('utf-8'))