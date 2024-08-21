variable "public_key" {
    type = string
    default = "~/.ssh/my_keys/id_ed25519.pub"
}

variable "ami" {
    #Ubuntu 20.04 LTS
    type = string
    default = "ami-0d267c22adcb5e686"
}

variable "ec2-count" {
    default = 1
}