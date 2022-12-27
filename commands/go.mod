module github.com/nuvolaris/openwhisk-cli/commands

go 1.15

replace github.com/apache/openwhisk-cli/wski18n => ../wski18n

require (
	github.com/apache/openwhisk-cli/wski18n v0.0.0-00010101000000-000000000000
	github.com/apache/openwhisk-client-go v0.0.0-20221221220036-71124f15c938
	github.com/apache/openwhisk-wskdeploy v0.0.0-20221221215944-0e9b45ff5ff3
	github.com/fatih/color v1.13.0
	github.com/ghodss/yaml v1.0.1-0.20190212211648-25d852aebe32
	github.com/mattn/go-colorable v0.1.13
	github.com/mitchellh/go-homedir v1.1.0
	github.com/onsi/ginkgo v1.16.5
	github.com/onsi/gomega v1.24.2
	github.com/spf13/cobra v1.6.1
	github.com/stretchr/testify v1.8.1
)
