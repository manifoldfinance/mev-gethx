variable "ETHEREUM_CLIENT" {
  default = "manifoldfinance/mev-gethx"
}

target "default" {
  tags = [ETHEREUM_CLIENT]
}

target "all" {
  inherits = ["default"]
  platforms = [
    "linux/amd64",
  ] 
}
