package main

import (
	"encoding/json"
	"net/http"

	spinhttp "github.com/fermyon/spin/sdk/go/v2/http"
)

func init() {
	spinhttp.Handle(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Header().Set("server", "spin")
		w.Header().Set("content-type", "application/json")
		msg := map[string]interface{}{"message": "Hello, world!"}
		json.NewEncoder(w).Encode(msg)
	})
}

func main() {}
