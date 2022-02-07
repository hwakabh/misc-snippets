package main

import "fmt"

// Define packaged variables
var pv = "Package variable"
// // Can not access outside the functions with fmt
// fmt.Println(pv)


func main() {
		// definitions + initializations
		var username = "hwakabh"
		fmt.Println(username)

		userid := "12345"
		fmt.Println(userid)

		lv := "Local variables"
		fmt.Println(pv)
		fmt.Println(lv)

}