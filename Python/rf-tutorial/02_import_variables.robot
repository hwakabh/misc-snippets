*** Settings ***
Documentation       Tests with importing vars from files
Variables           ./vars/companies.yaml

*** Variables ***
${MSG}      Hello Robot !!!


*** Test Cases ***
Say something
    print_message_to_stdout     ${MSG}

Call parameters in file
    Log To Console              ${EMPTY}
    print_message_to_stdout     ${vmware.name}
    print_message_to_stdout     ${vmware['founder']}


*** Keywords ***
print_message_to_stdout
    [Arguments]         ${msg}
    Log To Console      ${msg}
    
