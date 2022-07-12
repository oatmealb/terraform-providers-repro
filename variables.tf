variable "cluster_name" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "aws_auth_accounts" {
  type = list(string)
}
variable "aws_auth_roles" {
  nullable = false
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

}
