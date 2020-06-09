import yaml
import sys
import json

from vcsa.vcsa import VCenter, VApi, EsxiSoapParser
from nsxt.nsxt import Nsxt
from vio.vio import Vio
from vrops.vrops import VROps
from vrli.vrli import VRli


def read_config_from_file(conf_file_path):
    with open(conf_file_path, 'r') as f:
        data = f.read()
    return yaml.safe_load(data)


def main():
    CONFIG_FILE_PATH = './config.yaml'
    # TODO: Add check existence of configuration file.
    config = read_config_from_file(conf_file_path=CONFIG_FILE_PATH)

    # TODO: Split all functions by each product
    print('-----------------------------------------------------------')
    print('vCenter Server Configuration')
    print('-----------------------------------------------------------')
    for vcsas in config['vcenter']:
        for vcsa in vcsas.values():
            IPADDRESS = vcsa['hostname']
            USERNAME = vcsa['username']
            PASSWORD = vcsa['password']
            print('vCenter Server: {}'.format(IPADDRESS))
            vc = VCenter(ipaddress=IPADDRESS, username=USERNAME, password=PASSWORD)
            vapi = VApi(ipaddress=IPADDRESS, username=USERNAME, password=PASSWORD)

            print('>>> vCSA network configuration ...')
            vcsa_networks = vc.get('/rest/appliance/networking/interfaces')
            print('IP address: \t{}'.format(vcsa_networks['value'][0]['ipv4']['address']))
            print('Subnet Prefix: \t{}'.format(vcsa_networks['value'][0]['ipv4']['prefix']))
            print('Gateway: \t{}'.format(vcsa_networks['value'][0]['ipv4']['default_gateway']))

            print('>>> vCSA hostname information ...')
            vcsa_hostnames = vc.get('/rest/appliance/networking/dns/hostname')
            print('Hostname: \t{}'.format(vcsa_hostnames['value']))

            print('>>> vCSA DNS configuration ...')
            vcsa_dns = vc.get('/rest/appliance/networking/dns/servers')
            print('DNS Servers: \t{}'.format(vcsa_dns['value']['servers']))

            print('>>> vCSA NTP configuration ...')
            vcsa_ntp = vc.get('/rest/appliance/ntp')
            print('NTP Servers: \t{}'.format(vcsa_ntp['value']))

            print('>>> vCSA SSH configuration ...')
            vcsa_ssh_status = vc.get('/rest/appliance/access/ssh')
            print('SSH Services: {}'.format('Running' if vcsa_ssh_status['value'] == True else 'Not Running'))

            print('>>> vCHA configurations ...')
            vcsa_ha = vc.post('/rest/vcenter/vcha/cluster?action=get')
            print('Status : {}'.format(vcsa_ha['value']))

            print()
            print('-----------------------------------------------------------')
            print()
            # Retrieve all hostdata prior to compare with response of vSphere REST-API
            esxis = vapi.get_host_objects()
            print('>>> Datacenters')
            vcsa_dc = vc.get('/rest/vcenter/datacenter')
            for dc in vcsa_dc['value']:
                print('Name: {}'.format(dc['name']))
            print('>>> Clusters')
            vcsa_clusters = vc.get('/rest/vcenter/cluster')
            for cluster in vcsa_clusters['value']:
                print('Name: {0}\t(DRS Enabled : {1}, HA Enabled : {2})'.format(cluster['name'], cluster['drs_enabled'], cluster['ha_enabled']))
                print('>>>>>> Managed ESXi Host configs')
                vcsa_hosts = vc.get('/rest/vcenter/host?filter.clusters={}'.format(cluster['cluster']))
                for host in vcsa_hosts['value']:
                    esxi_parser = EsxiSoapParser()
                    host_info = dict()
                    print('>>>>>>>>> [ {} ] Network Configurations'.format(host['name']))
                    target_host = [esxi for esxi in esxis if esxi.name == host['name']][0]
                    host_pnics = esxi_parser.get_host_pnics(target_host)
                    host_vnics = esxi_parser.get_host_vnics(target_host)
                    host_vswitches = esxi_parser.get_host_vswitches(target_host)
                    host_portgroups = esxi_parser.get_host_portgroups(target_host)
                    host_info.update({
                        'pnics': host_pnics,
                        'vswitches': host_vswitches,
                        'portgroups': host_portgroups,
                        'vnics': host_vnics
                    })
                    print(json.dumps(host_info, indent=3, separators=(',', ': ')))
                    print('>>>>>>>>> [ {} ] SSH configurations'.format(host['name']))
                    print('SSH service : {}'.format(esxi_parser.get_host_ssh_status(target_host)))
                    print()

    # print()
    # print('-----------------------------------------------------------')
    # print('NSX-T Configuration')
    # print('-----------------------------------------------------------')
    # for nsxts in config['nsx']:
    #     for nsxt in nsxts.values():
    #         NSX_MGR = nsxt['hostname']
    #         NSX_USERNAME = nsxt['username']
    #         NSX_PASSWORD = nsxt['password']
    #         print('NSX-T Manager: {}'.format(NSX_MGR))
    #         nsx = Nsxt(ipaddress=NSX_MGR, username=NSX_USERNAME, password=NSX_PASSWORD)
    #         # Fetch only management network information
    #         print('>>> NSX-T Management Network information ...')
    #         nsx_networks = nsx.get('/api/v1/node/network/interfaces')
    #         print('IP Address: \t{}'.format(nsx_networks['results'][0]['ip_addresses'][0]['ip_address']))
    #         print('Netmask: \t{}'.format(nsx_networks['results'][0]['ip_addresses'][0]['netmask']))
    #         print('Gateway: \t{}'.format(nsx_networks['results'][0]['default_gateway']))

    #         print('>>> NSX-T Hostname configuration ...')
    #         nsx_hostname = nsx.get('/api/v1/node')
    #         print('Hostname: \t{}'.format(nsx_hostname['fully_qualified_domain_name']))

    #         print('>>> NSX-T DNS configuration ...')
    #         nsx_dns = nsx.get('/api/v1/node/network/name-servers')
    #         print('DNS Servers: \t{}'.format(nsx_dns['name_servers']))

    #         print('>>> NSX-T NTP configuration ...')
    #         nsx_ntp = nsx.get('/api/v1/node/services/ntp')
    #         print('NTP Servers: \t{}'.format(nsx_ntp['service_properties']['servers']))
    #         print('-----------------------------------------------------------')

    # print()
    # print('-----------------------------------------------------------')
    # print('VIO Configuration')
    # print('-----------------------------------------------------------')
    # for vios in config['vio']:
    #     for vio in vios.values():
    #         VIO_MGR = vio['hostname']
    #         VIO_USERNAME = vio['username']
    #         VIO_PASSWORD = vio['password']
    #         print('VIO Manager: {}'.format(VIO_MGR))
    #         viomgr = Vio(ipaddress=VIO_MGR, username=VIO_USERNAME, password=VIO_PASSWORD)

    #         print('>>> VIO Network information ...')
    #         vio_networks = viomgr.get('/apis/vio.vmware.com/v1alpha1/namespaces/openstack/vioclusters/viocluster1')
    #         print('> Management Network')
    #         print('IP Ranges: \t{}'.format(vio_networks['spec']['cluster']['network_info'][0]['static_config']['ip_ranges']))
    #         print('Netmask: \t{}'.format(vio_networks['spec']['cluster']['network_info'][0]['static_config']['netmask']))
    #         print('Gateway: \t{}'.format(vio_networks['spec']['cluster']['network_info'][0]['static_config']['gateway']))
    #         print('> API Network')
    #         print('IP Ranges: \t{}'.format(vio_networks['spec']['cluster']['network_info'][1]['static_config']['ip_ranges']))
    #         print('Netmask: \t{}'.format(vio_networks['spec']['cluster']['network_info'][1]['static_config']['netmask']))
    #         print('Gateway: \t{}'.format(vio_networks['spec']['cluster']['network_info'][1]['static_config']['gateway']))
    #         vio_nodes = viomgr.get('/api/v1/nodes')
    #         print('> manager/controller nodes')
    #         for node in vio_nodes['items']:
    #             print('Nodename: \t{}'.format(node['metadata']['name']))
    #             print('  PodCIDR: \t{}'.format(node['spec']['podCIDR']))
    #             print('  IntIP: \t{}'.format(node['status']['addresses'][0]['address']))
    #             print('  ExtIP: \t{}'.format(node['status']['addresses'][1]['address']))
    #         print('>>> VIO DNS configurations ...')
    #         print('> Management Network')
    #         print('DNS Servers: \t{}'.format(vio_networks['spec']['cluster']['network_info'][0]['static_config']['dns']))
    #         print('> API Network')
    #         print('DNS Servers: \t{}'.format(vio_networks['spec']['cluster']['network_info'][1]['static_config']['dns']))
    #         # TODO: Research NTP API Endpoints for Kubernetes
    #         print('-----------------------------------------------------------')

    print()
    print('-----------------------------------------------------------')
    print('vROps Configuration')
    print('-----------------------------------------------------------')
    for vropses in config['vrops']:
        for vrops in vropses.values():
            VROPS_IPADDR = vrops['hostname']
            VROPS_USERNAME = vrops['username']
            VROPS_PASSWORD = vrops['password']
            print('vROps: {}'.format(VROPS_IPADDR))
            vrops_api = VROps(ipaddress=VROPS_IPADDR, username=VROPS_USERNAME, password=VROPS_PASSWORD)
            # TODO: Add functions to get deployment rule(currently vROps in Labs are non-clustered)

            print('>>> vROps Network information ...')
            vrops_ip = vrops_api.get('/casa/node/status')
            print('IP Address: \t{}'.format(vrops_ip['address']))
            vrops_nodeconf = vrops_api.get('/casa/node/config')
            print('Netmask: \t{}'.format(vrops_nodeconf['network_properties']['network1_netmask']))
            print('Gateway: \t{}'.format(vrops_nodeconf['network_properties']['default_gateway']))

            print('>>> vROps Hostname configuration ...')
            print('Nodename: \t{}'.format(vrops_nodeconf['node_name']))

            print('>>> vROps DNS configuration ...')
            print('DNS Servers: \t{}'.format(vrops_nodeconf['network_properties']['domain_name_servers']))
            print('Domain Name: \t{}'.format(vrops_nodeconf['network_properties']['domain_name']))
            print('Search Path: \t{}'.format(vrops_nodeconf['network_properties']['domain_search_path']))

            print('>>> vROps NTP configuration ...')
            print('NTP Servers: \t{}'.format(vrops_nodeconf['ntp_servers']))
            print('-----------------------------------------------------------')

    print()
    print('-----------------------------------------------------------')
    print('vRLI Configuration')
    print('-----------------------------------------------------------')
    for vrlis in config['vrli']:
        for vrli in vrlis.values():
            VRLI_IPADDR = vrli['hostname']
            VRLI_USERNAME = vrli['username']
            VRLI_PASSWORD = vrli['password']
            VRLI_PROVIDER = vrli['provider']
            print('vRLI: {}'.format(VRLI_IPADDR))
            vrli_api = VRli(ipaddress=VRLI_IPADDR, username=VRLI_USERNAME, password=VRLI_PASSWORD, provider=VRLI_PROVIDER)

            print('>>> Version information')
            vrli_version = vrli_api.get('/api/v1/version')
            print('{0} (Release Type: {1})'.format(vrli_version['version'], vrli_version['releaseName']))

            # TODO: Configure Labs vRLI as cluster and set vIP
            print('>>> Cluster configurations ...')
            vrli_clusters = vrli_api.get('/api/v1/cluster/vips')
            print(vrli_clusters)
            print('>>> NTP Configurations ...')
            vrli_ntp = vrli_api.get('/api/v1/time/config')
            print(vrli_ntp['ntpConfig']['ntpServers'])

            ## Download & Extract configuration dump via REST-API
            print('>>> SMTP Configurations ...')
            vrli_config = vrli_api.dump_config_file(dump_filename='20200709_vrli_01.conf')
            vrli_smtp = vrli_config['smtpConfig']
            print(json.dumps(vrli_smtp, indent=3, separators=(',', ': ')))

            print('>>> Authentication source configurations ...')
            print('>>>>>> Active Directories')
            vrli_ads = vrli_api.get('/api/v1/ad')
            print(vrli_ads)
            print('>>>>>> vIDM')
            vrli_vidm_status = vrli_api.get('/api/v1/vidm/status')
            print('Status: {}'.format(vrli_vidm_status['state']))
            vrli_vidms = vrli_api.get('/api/v1/vidm')
            print(json.dumps(vrli_vidms, indent=3, separators=(',', ': ')))


if __name__ == "__main__":
    main()
