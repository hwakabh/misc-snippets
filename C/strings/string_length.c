#include <stdio.h>    // printf()
#include <strings.h>  // strlen()

int main(void) {
    char first[] = "Hello";
    char second[] = "World";
    // Join strings with printf()
    printf(">>> %s %s !!\n", first, second);

    // Listed all the characters in string(= Array of Char)
    printf("Char | ASCII | POINTER\n");
    int l = strlen(first);
    for (int i = 0; i < l; i++) {
        printf("%c | %d | %p\n", first[i], first[i], &first[i]);
    }

    // Access to EOS
    printf(">>> Displaying EOS of string variable.\n");
    printf("Char | ASCII | POINTER\n");
    printf("%c | %d | %p\n", first[5], first[5], &first[5]);
    // If index over the elements number, it triggers segmentation fault
    // printf("%c\n", first[100]);

    return 0;
}
