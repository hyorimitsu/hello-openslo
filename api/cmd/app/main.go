package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/api/greet", func (w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello, World")
	})
	http.ListenAndServe(fmt.Sprintf(":%s", os.Getenv("PORT")), nil)
}
