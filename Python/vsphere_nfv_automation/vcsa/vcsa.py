import requests
import json
import ssl
import atexit
import urllib3
from urllib3.exceptions import InsecureRequestWarning
urllib3.disable_warnings(InsecureRequestWarning)

from pyVim.connect import SmartConnect, Disconnect
from pyVmomi import vim


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
        # POST to fetch token
        token = self.post(
            urlsuffix='/rest/com/vmware/cis/session',
            headers=self.headers,
            reqbody=''
        )
        # Update headers
        self.headers['vmware-api-session-id'] = token.get('value')
    
    def get(self, urlsuffix):
        uri = '{0}{1}'.format(self.baseuri, urlsuffix)
        res = requests.get(uri, headers=self.headers, verify=False)
        return json.loads(res.text)

    def post(self, urlsuffix, headers=None, reqbody=None):
        uri = '{0}{1}'.format(self.baseuri, urlsuffix)
        res = requests.post(uri, auth=(self.username, self.password), headers=self.headers, data=reqbody, verify=False)
        return json.loads(res.text)


class VApi():
    def __init__(self, ipaddress, username, password):
        self.ipaddress = ipaddress
        self.username = username
        self.password = password
        self.context = None
    
    def establish_session(self):
        if hasattr(ssl, '_create_unverified_context'):
            self.context = ssl._create_unverified_context()
        vc_session = SmartConnect(host=self.ipaddress, user=self.username, pwd=self.password, sslContext=self.context)
        atexit.register(Disconnect, vc_session)
        return vc_session.content

    def get_host_objects(self):
        ret = self.establish_session()
        host_view = ret.viewManager.CreateContainerView(ret.rootFolder,[vim.HostSystem], True)
        hostlist = [host for host in host_view.view]
        host_view.Destroy()
        return hostlist

