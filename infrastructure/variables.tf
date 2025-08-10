variable "auth_url" { 
    type = string
    default = "https://api.pub1.infomaniak.cloud/identity/v3"
}
variable "username" {
    type = string
    default = "PCU-88WL8TD"
}
variable "password" {
    type = string
    sensitive = true
}
variable "project_name" {
    type = string
    default = "PCP-88WL8TD"
}
variable "region" {
    type = string
    default = "dc4-a"
}
variable "external_network" {
    type = string
    default = "ext-floating1"
}
variable "number_of_workers" {
    type = number
    default = 2
}