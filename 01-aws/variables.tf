# can use any name here except speical keywords
variable "vpc_cidr_block" {
  default     = "10.0.0.0/16"
  description = "CIDR BLock for the VPC"
  type        = string

}

variable "web_subnet" {
  default     = "10.0.0.0/24"
  description = "Websubnet"
  type        = string


}

variable "subnet_zone" {
    default     = "us-east-1a"
}

variable "main_vpc_name" {
  default     = "Main VPC IGW"
  
}


variable "my_public_ip"{
  
}

variable "TF_VAR_ACCESS_KEY" {

}

variable "TF_VAR_SECRET_KEY" {
  
}