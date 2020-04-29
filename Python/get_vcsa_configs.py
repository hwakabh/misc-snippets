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
    print('>>> Starting to get vCenter configs ...')
    VCSA_IP = 'vcsa01.nfvlab.local'
    VCSA_USERNAME = 'administrator@vsphere.local'
    VCSA_PASSWORD = 'VMware1!'

    vcsa = VCenter(ipaddress=VCSA_IP, username=VCSA_USERNAME, password=VCSA_PASSWORD)

    print('>>> vCSA network configuration ...')
    vcsa_networks = vcsa.get('/rest/appliance/networking/interfaces')
    print('IP address: \t{}'.format(vcsa_networks['value'][0]['ipv4']['address']))
    print('Subnet Prefix: \t{}'.format(vcsa_networks['value'][0]['ipv4']['prefix']))
    print('Gateway: \t{}'.format(vcsa_networks['value'][0]['ipv4']['default_gateway']))

    print('>>> vCSA hostname information ...')
    vcsa_hostnames = vcsa.get('/rest/appliance/networking/dns/hostname')
    print('Hostname: \t{}'.format(vcsa_hostnames['value']))

    print('>>> vCSA DNS configuration ...')
    vcsa_dns = vcsa.get('/rest/appliance/networking/dns/servers')
    print('DNS Servers: \t{}'.format(vcsa_dns['value']['servers']))

    print('>>> vCSA NTP configuration ...')
    vcsa_ntp = vcsa.get('/rest/appliance/ntp')
    print('NTP Servers: \t{}'.format(vcsa_ntp['value']))
