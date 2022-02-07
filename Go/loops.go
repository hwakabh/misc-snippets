package main

import "fmt"


func main() {
		for i := 0; i < 10; i++ {
				var msg = fmt.Sprintf("Hello No. %d", i)
				fmt.Println(msg)
		}

		// fmt.Println(">>> Staring closed-loop ...")
		// j := 0
		// for {
		// 		j++
		// 		fmt.Println(j)
		// }
}