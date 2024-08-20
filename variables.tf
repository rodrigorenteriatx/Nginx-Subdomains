variable "public_key" {
    type = string
    default = "~/.ssh/my_keys/id_ed25519.pub"
}

variable "ami" {
    #CentOS 8
    type = string
    default = "ami-0cdb8266fcd5d3d63"
}

variable "ec2-count" {
    default = 1
}