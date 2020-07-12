#ingresar credenciales
variable "access_key" {}
variable "secret_key" {}
variable "region" {}
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

variable "elastic_search_name" {
  type        = "string"
  description = "indicar el nombre para el elastic search"
}

variable "instance_type" {
  type        = "string"
  description = "indicar el tamaño de elastic search ejemplo: dev t2.small.elasticsearch prod m5.large.elasticsearch"
}

variable "id_account" {
  type        = "string"
  description = "indicar el id de la cuenta ejemplo: 933852400332"
}


variable "volume_size" {
  type        = "string"
  description = "indicar el tamaño del disco ejemplo: 30"
}


variable "vpc_id" {
  type        = "string"
  description = "indicar el vpc_id de la vpc donde creara el recurso"
}

variable "subnetid_1" {
  type        = "string"
  description = "indicar el subnetid_1"
}

