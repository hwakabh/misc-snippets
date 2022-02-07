package main

import "fmt"

func main() {
		fmt.Print("hello world with print")
		// Nothing happend
		fmt.Print()
		// Linebreak with no argument
		fmt.Println()
		fmt.Println("hello world with println")


		// Constants
		const username string = "hwakabh"
		const userid int = 123

		// Concatinate string
		fmt.Println("My name is " + username)

    // Using placeholders with Sprintf()
    var f string = fmt.Sprintf("My name is %s and id is %d", username, userid)
    fmt.Println(f)

		// // Can not use data-type guess for const
		// const userpass := 12345
		// fmt.Println(userpass)

}