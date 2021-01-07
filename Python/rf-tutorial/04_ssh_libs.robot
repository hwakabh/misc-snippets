*** Settings ***
Documentation     Testings with SSHLibrary
Library           SSHLibrary

*** Variables ***
${TARGET_IP}      172.16.111.153
${USERNAME}       root
${PASSWORD}       VMware1!

*** Test Cases ***
Print configurations to stdout
    Log To Console    ${EMPTY}
    Log To Console    TARGET_IP: ${TARGET_IP}
    Log To Console    USERNAME: ${USERNAME}
    Log To Console    PASSWORD: ${PASSWORD}

Open SSH Connection to target
    Log To Console              ${EMPTY}
    open_connection_and_login   ${TARGET_IP}  ${USERNAME}  ${PASSWORD}

Get hostname of target
    Log To Console    ${EMPTY}
    ${fqdn}=          Execute Command   cat /etc/hostname
    # Log To Console    ${fqdn}
    Should Be Equal   ${fqdn}   viomgr02.nfvlab.local

Get hosts config
    Log To Console    ${EMPTY}
    ${hosts}=         Execute Command   cat /etc/hosts
    # Log To Console    ${hosts}
    Should Contain    ${hosts}    viomgr02.nfvlab.local


*** Keywords ***
open_connection_and_login
    [Arguments]       ${hostname}   ${username}   ${password}
    # Log To Console    Trying to connect ${hostname} ...
    Open Connection   ${hostname}
    Login             ${username}   ${password}
