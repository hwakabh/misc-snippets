#include <stdio.h>    // FILE, fopen(), fgets(), fclose()

int main(int argc, char *argv[])
{
    // Validate command line arguments
    if (argc != 2) {
        printf("ERROR: Missing arguments or Too many arguments provided.\n");
        return 1;
    }
    // Instanciate FILE strucuture and reserve memory for file contents
    FILE *file;
    char lines[256] = {'\0'};

    char *filename = argv[1];
    file = fopen(filename, "r");

    if (file == NULL) {
        perror(">>> Failed to open file. ");
        return -1;
    } else {
        printf(">>> File opened successfully.\n");
        printf(">>> Starting to read data...\n");

        while (fgets(lines, 256, file) != NULL) {
            printf("%s", lines);
        }

        fclose(file);
        return 0;
    }

}