*** Settings ***
Documentation   Tutorial with external-libs, SeleniumLibrary
Library         SeleniumLibrary

*** Test Cases ***
Check Page Title
    # instance name should be "Chrome" with case-sentitivity, instead of "chrome".
    Create Webdriver        Chrome                      executable_path=/Users/hwakabayashi/git/rf-tutorials/bin/chromedriver
    Open Browser            https://robotframework.org  Chrome
    Title Should Be         Robot Framework
    Close Browser

