package main

import "fmt"

// Define data-types of args & returns
func say_message(n string) string {
		return "hello my name is " + n
}


func main() {
		const alice = "Alice"
		const bob = "Bob"
		const charie = "Charie"

		// Call functions
		say_message("hwakabh")
		//-> Nothing happens on stdout

    // Using functions and store results to variables
		m1 := say_message(alice)
		fmt.Println(m1)

		var m2 = say_message(bob)
		fmt.Println(m2)

		var m3 string = say_message(charie)
		fmt.Println(m3)

}