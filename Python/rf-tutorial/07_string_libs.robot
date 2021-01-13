*** Settings ***
Documentation   Tutorial with standard-libs, String
Library         String

*** Variables ***
${COMPANY}    Google

*** Test Cases ***
Print Out Variables
    LOG TO CONSOLE  ${COMPANY}

Replace Some Characters
    ${s1}=  REPLACE STRING USING REGEXP   ${COMPANY}    [A-Z]     foo
    LOG TO CONSOLE  ${s1}

Remove Some Characters
    ${s2}=  REMOVE STRING USING REGEXP    ${COMPANY}    G
    LOG TO CONSOLE  ${s2}