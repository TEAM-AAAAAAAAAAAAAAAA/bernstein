// https://github.com/TEAM-AAAAAAAAAAAAAAAA/bernstein

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
    files, err := ioutil.ReadDir(".")
    if err != nil {
        log.Fatal(err)
    }
    for _, file := range files {
        if file.Mode().IsRegular() {
            if filepath.Ext(file.Name()) == ".yaml" {
                fmt.Println(file.Name())
                file := "cluster-architecture.yml"
                f, err := os.Open(file)
                if err != nil {
                    log.Fatalf("failed opening %s: %s", file, err)
                }
                v, err := validator.New(nil, validator.Opts{Strict: true})
                if err != nil {
                    log.Fatalf("failed initializing validator: %s", err)
                }
                for i, res := range v.Validate(file, f) {
                    if res.Status == validator.Invalid {
                        log.Fatalf("resource %d in file %s is not valid: %s", i, file, res.Err)
                    }
                    if res.Status == validator.Error {
                        log.Fatalf("error while processing resource %d in file %s: %s", i, file, res.Err)
                    }
                }
            }
        }
    }
}
