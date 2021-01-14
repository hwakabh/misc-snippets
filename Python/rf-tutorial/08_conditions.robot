*** Settings ***
Documentation   Tutorial with conditions(if/else)
Library         String

*** Variables ***
${COMPANY}    Google

*** Test Cases ***
Simple If Statement
    RUN KEYWORD IF  '${COMPANY}' == 'Google'
    ...  LOG TO CONSOLE  \nCompany code is GOOGL

Multiple Keywords In If Statement
    RUN KEYWORD IF  '${COMPANY}' == 'Google'
    ...  RUN KEYWORDS
    ...  LOG TO CONSOLE  \nCompany code is GOOGL
    ...  AND
    ...  LOG TO CONSOLE  Founder is Larry Page

Simple If Else Statement
    RUN KEYWORD IF  '${COMPANY}' != 'Google'
    ...  LOG TO CONSOLE  \nCompany code is GOOGLE
    ...  ELSE
    ...  LOG TO CONSOLE  \nAnother company

Multiple Keywords In If Else Statement
    RUN KEYWORD IF  '${COMPANY}' != 'Google'
    ...  RUN KEYWORDS
    ...  LOG TO CONSOLE  \nCompany code is GOOGL
    ...  AND
    ...  LOG TO CONSOLE  Founder is Larry Page
    ...  ELSE
    ...  RUN KEYWORDS
    ...  LOG TO CONSOLE  \nAnother company
    ...  AND
    ...  LOG TO CONSOLE  Company name code is not GOOGL
