*** Settings ***
Documentation   Tutorial with external-libs, RequestLibrary
Library         RequestsLibrary

*** Variables ***
${BASEURL}=   https://swapi.dev

*** Test Cases ***
# >= robotframework 3.2.1 (contains Depreciated warnings)
Test with plane GET method
    CREATE SESSION    swapi   ${BASEURL}    disable_warnings=1
    ${res}=   GET REQUEST  swapi  /api/people/1
    REQUEST SHOULD BE SUCCESSFUL  ${res}
    ${body}=  TO JSON  ${res.text}  pretty_print=True
    LOG TO CONSOLE  ${EMPTY}
    LOG TO CONSOLE  ${body}

# robotframework 3.2.2 or higher
Test with plane GET method with accessing some keys in JSON request
    CREATE SESSION    swapi   ${BASEURL}    disable_warnings=1
    ${res}=   GET ON SESSION  swapi  /api/people/1
    REQUEST SHOULD BE SUCCESSFUL  ${res}
    ${body}=  SET VARIABLE  ${res.json()}
    LOG TO CONSOLE  ${EMPTY}
    LOG TO CONSOLE  Name of people is: ${body['name']}

*** Keywords ***
