data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    bucket = "finally-animatronics-terraform-state"     
    key    = "dev/base/terraform.tfstate"         
    region = "us-west-1"
  }
}