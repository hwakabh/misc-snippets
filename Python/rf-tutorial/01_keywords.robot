*** Settings ***
Documentation       Tests with using keywords  


*** Variables ***
${DEFAULT_MSG}      RobotFramworking


*** Test Cases ***
Test saying something
    say_hello

Test with greet
    greeting

Test saying something again
    print_message_to_stdout     My name is Hiroyuki

Test saying something again and again
    print_message_to_stdout     ${DEFAULT_MSG}

Test all
    say_hello
    greeting
    print_message_to_stdout     My name is Robot
    print_message_to_stdout     ${DEFAULT_MSG}


*** Keywords ***
say_hello
    Log To Console      Hello!!!

greeting
    Log To Console      ${DEFAULT_MSG}

print_message_to_stdout
    [Arguments]         ${msg}
    Log To Console      ${msg}
    
