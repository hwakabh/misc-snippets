from urllib import request
import base64
import json
import ssl
ssl._create_default_https_context = ssl._create_unverified_context


# REST-API Client for vCSA
class VCenter():
    def __init__(self, ipaddress, username, password):
        self.ipaddress = ipaddress
        self.username = username
        self.password = password
        self.headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
        }
        self.baseuri = 'https://{}'.format(self.ipaddress)
        self.set_token()
    
    def set_token(self):
        token_fetch_endpoint = 'https://{}/rest/com/vmware/cis/session'.format(self.ipaddress)
        HEADER_BASIC = base64.b64encode('{}:{}'.format(self.username, self.password).encode('utf-8'))
        self.headers['Authorization'] = 'Basic {}'.format(HEADER_BASIC.decode('utf-8'))
        # POST to fetch token
        token = self.post(uri=token_fetch_endpoint, headers=self.headers).get('value', None)
        # Update headers
        self.headers.pop('Authorization')
        self.headers['vmware-api-session-id'] = token
    
    def get(self, urlsuffix):
        uri = '{0}{1}'.format(self.baseuri, urlsuffix)
        req = request.Request(url=uri, headers=self.headers)
        with request.urlopen(req) as res:
            body = res.read()
        return json.loads(body.decode('utf-8'))

    def post(self, uri, headers=None, reqbody=None):
        req = request.Request(url=uri, headers=headers, data=''.encode('utf-8'))
        with request.urlopen(req) as res:
            body = res.read()
        return json.loads(body.decode('utf-8'))
  

if __name__ == "__main__":
    print('>>> Starting vCSA Health checks ...')
    VCSA_IP = 'vcsa02.nfvlab.local'
    VCSA_USERNAME = 'administrator@vsphere.local'
    VCSA_PASSWORD = 'VMware1!'

    vcsa = VCenter(ipaddress=VCSA_IP, username=VCSA_USERNAME, password=VCSA_PASSWORD)
    # vCSA status check (02-07)
    ENDPOINTS = [
        {'DB storage status': '/rest/appliance/health/database-storage'},
        {'System Load Status': '/rest/appliance/health/load'},
        {'Memory Status': '/rest/appliance/health/mem'},
        {'Storage Status': '/rest/appliance/health/storage'},
        {'Swap storage Status': '/rest/appliance/health/swap'},
        {'Overall Status': '/rest/appliance/health/system'},
    ]
    for ep in ENDPOINTS:
        for k, v in ep.items():
            responese = vcsa.get(v)
            if responese['value'] == 'green':
                status = 'OK'
            else:
                status = 'Error: (status: {})'.format(responese['value'])
            print('>>> vCSA: {0}: \t[ {1} ]'.format(k, status))
