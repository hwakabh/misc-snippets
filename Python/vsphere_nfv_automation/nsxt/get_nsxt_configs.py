from urllib import request
import base64
import json
import ssl
ssl._create_default_https_context = ssl._create_unverified_context


# REST-API Client for NSX-T Manager
class Nsx():
    def __init__(self, ipaddress, username, password):
        self.ipaddress = ipaddress
        self.username = username
        self.password = password
        self.headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
        }
        self.baseuri = 'https://{}'.format(self.ipaddress)
        self.set_basic_auth_header()
    
    def set_basic_auth_header(self):
        HEADER_BASIC = base64.b64encode('{}:{}'.format(self.username, self.password).encode('utf-8'))
        self.headers['Authorization'] = 'Basic {}'.format(HEADER_BASIC.decode('utf-8'))
    
    def get(self, urisuffix):
        uri = '{0}{1}'.format(self.baseuri, urisuffix)
        req = request.Request(url=uri, headers=self.headers)
        with request.urlopen(req) as res:
            body = res.read()
        return json.loads(body.decode('utf-8'))



if __name__ == "__main__":
    print('>>> Starting to get NSX-T configs ...')
    NSXT_IP = 'nsxmgr02.nfvlab.local'
    NSXT_USERNAME = 'admin'
    NSXT_PASSWORD = 'VMware1!VMware1!'

    nsx = Nsx(ipaddress=NSXT_IP, username=NSXT_USERNAME, password=NSXT_PASSWORD)
    # Fetch only management network information
    print('>>> NSX-T Management Network information ...')
    nsx_networks = nsx.get('/api/v1/node/network/interfaces')
    print('IP Address: \t{}'.format(nsx_networks['results'][0]['ip_addresses'][0]['ip_address']))
    print('Netmask: \t{}'.format(nsx_networks['results'][0]['ip_addresses'][0]['netmask']))
    print('Gateway: \t{}'.format(nsx_networks['results'][0]['default_gateway']))

    print('>>> NSX-T Hostname configuration ...')
    nsx_hostname = nsx.get('/api/v1/node')
    print('Hostname: \t{}'.format(nsx_hostname['fully_qualified_domain_name']))

    print('>>> NSX-T DNS configuration ...')
    nsx_dns = nsx.get('/api/v1/node/network/name-servers')
    print('DNS Servers: \t{}'.format(nsx_dns['name_servers']))

    print('>>> NSX-T NTP configuration ...')
    nsx_ntp = nsx.get('/api/v1/node/services/ntp')
    print('NTP Servers: \t{}'.format(nsx_ntp['service_properties']['servers']))
