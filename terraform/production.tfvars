env                  = "production"
vpc_cidr             = "10.1.0.0/16"
public-subnet-cidr   = ["10.1.1.0/24", "10.1.2.0/24"]
private-subnet-cidr  = ["10.1.3.0/24", "10.1.4.0/24"]
database-subnet-cidr = ["10.1.5.0/24", "10.1.6.0/24"]
multi-az-deployment  = true
key_name             = "sandip"