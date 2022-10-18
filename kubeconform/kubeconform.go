// https://github.com/TEAM-AAAAAAAAAAAAAAAA/bernstein

// cd kubeconform
// go mod init kubeconform
// go mod tidy
// go run kubeconform.go

package main

import (
    "github.com/yannh/kubeconform/pkg/validator"
    "os"
    "fmt"
    "io/ioutil"
    "log"
    "path/filepath"
)

func main() {
    files, err := ioutil.ReadDir("..")
    if err != nil {
        log.Fatal(err)
    }
    for _, file := range files {
        if file.Mode().IsRegular() {
            filename := "../" + file.Name()
            if filepath.Ext(filename) == ".yaml" {
                fmt.Println(filename)
                f, err := os.Open(filename)
                if err != nil {
                    log.Fatalf("failed opening %s: %s", filename, err)
                }
                v, err := validator.New(nil, validator.Opts{Strict: true})
                if err != nil {
                    log.Fatalf("failed initializing validator: %s", err)
                }
                for i, res := range v.Validate(filename, f) {
                    if res.Status == validator.Invalid {
                        log.Fatalf("resource %d in file %s is not valid: %s", i, filename, res.Err)
                    }
                    if res.Status == validator.Error {
                        log.Fatalf("error while processing resource %d in file %s: %s", i, filename, res.Err)
                    }
                }
            }
        }
    }
}
