#include <stdio.h>    // printf()
#include <stdlib.h>   // getenv(), EXIT_SUCCESS, EXIT_FAILURE

int get_no_exist_env(void);

int main(void) {
    char *os_shell;
    os_shell = getenv("SHELL");
    // Try to get env which is not defined
    int is_env = get_no_exist_env();
    printf(">>> Result of get_no_exist_env() : %d\n", is_env);

    printf(">>> Current shell : %s \n", os_shell);  // >>> Current shell : /bin/bash
    // Can be referred EXIT_SUCCESS with `echo $?`
    return EXIT_SUCCESS;
}

int get_no_exist_env(void) {
    char *env;
    env = getenv("WRONG_ENV_NAME");
    // If name of environmental varialbe does not be defined, get_env() returns null
    printf(">>> Value of env : %s \n", env);    // >>> Value of env : (null)
    return EXIT_FAILURE;
}
