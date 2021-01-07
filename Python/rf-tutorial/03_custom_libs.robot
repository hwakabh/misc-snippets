*** Settings ***
Documentation       Tests with custom-libs
Library             MyAwesomeFunctions.py

*** Variables ***
${DEFAULT_MESSAGE}      RobotFramework

*** Test Cases ***
Initial Setup
    print_message_to_stdout     custom-libs

Call Default Message
    print_message_to_stdout     ${DEFAULT_MESSAGE}

Call function in custom-libs
    print_hello_to_stdout

Call function in custom-libs with args
    Log To Console      ${EMPTY}
    greet_to_console
    greet_to_console    ${DEFAULT_MESSAGE}
    greet_to_console    Hiroyuki

Checking my function names
    Log To Console      ${EMPTY}
    GREET TO CONSOLE
    GREET_TO_CONSOLE
    GREETTOCONSOLE
    greet to console
    greettoconsole

Using multiple args for custom function
    Log To Console      ${EMPTY}
    print_company_info
    ...  name=Google, Inc
    ...  code=GOOGL
    ...  year=1998
    ...  founder=Larry Page

*** Keywords ***
print_message_to_stdout
    [Arguments]         ${msg}
    Log To Console      ${msg}
