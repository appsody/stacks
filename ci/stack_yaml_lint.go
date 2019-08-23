package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"reflect"
	"strings"

	"fatih/structs"

	"gopkg.in/yaml.v2"
)

type stack struct {
	Name        string `yaml: "name"`
	Version     string `yaml: "version"`
	Description string `yaml: "description"`
	License     string `yaml: "license"`
	Language    string `yaml: "language"`
	//DefaultTemplate string `yaml: "default-template"`
}

func (s *stack) validateYaml() *stack {
	arg := os.Args[1]
	stackyaml, err := ioutil.ReadFile(arg)
	if err != nil {
		log.Printf("stackyaml.Get err   #%v ", err)
	}
	err = yaml.Unmarshal(stackyaml, s)
	if err != nil {
		log.Fatalf("Unmarshal: %v", err)
	}

	missingField := structs.HasZero(s)

	if missingField == true {
		fmt.Println("ERROR: MISSING FIELD")
	}

	return s
}

func (s *stack) checkVersion() *stack {
	versionNo := strings.Split(s.Version, ".")

	if len(versionNo) < 3 {
		fmt.Println("ERROR: Version is not formatted as major.minor.patch")
	}

	return s
}

func main() {
	var s stack
	s.validateYaml()

	v := reflect.ValueOf(&s).Elem()
	yamlValues := make([]interface{}, v.NumField())
	errorPath := strings.Split(os.Args[1], "/stacks")

	for i := 0; i < v.NumField(); i++ {
		yamlValues[i] = v.Field(i).Interface()
		if yamlValues[i] == "" {
			fmt.Println("ERROR: Missing value for field: " + strings.ToLower(v.Type().Field(i).Name) + " in " + errorPath[1])
		}
	}

	// if len(yamlValues) < 6 {
	// 	fmt.Println("ERROR: Missing field in " + errorPath[1])
	// }

	s.checkVersion()
}
