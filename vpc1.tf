#Creating a new VPC
resource "aws_vpc" "eh01-vpc-threetier" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true

    tags = {
        Name = "eh01-vpc-threetier"
    }
}

#Creating a public subnet for web tier
resource "aws_subnet" "eh01_sub_ezweb" {
    count = length(var.ez_websub_cidr)
    vpc_id = aws_vpc.eh01-vpc-threetier.id
    cidr_block = element(var.ez_websub_cidr, count.index)
    availability_zone = element(var.availability_zone, count.index)

    tags = {
      Name = "eh01-sub-ezweb-${count.index + 1}"
    }
}

# Allocate Elastic IP for NAT Gateway
resource "aws_eip" "eh01_nat_eip" {

  tags = {
    Name = "eh01-nat-eip"
  }
}

# Create NAT Gateway in internet web wubnet
resource "aws_nat_gateway" "eh01_natgw_ezweb" {
  allocation_id = aws_eip.eh01_nat_eip.id
  subnet_id     = aws_subnet.eh01_sub_ezweb[0].id

  tags = {
    Name = "eh01_natgw_ezweb"
  }
}

#Creating a private subnet for app tier
resource "aws_subnet" "eh01_sub_izapp" {
    count = length(var.iz_appsub_cidr)
    vpc_id = aws_vpc.eh01-vpc-threetier.id
    cidr_block = element(var.iz_appsub_cidr, count.index)
    availability_zone = element(var.availability_zone, count.index)

    tags = {
      Name = "eh01-sub-izapp-${count.index + 1}"
    }
}

#Creating a private subnet for database tier
resource "aws_subnet" "eh01_sub_izdb" {
    count = length(var.iz_dbsub_cidr)
    vpc_id = aws_vpc.eh01-vpc-threetier.id
    cidr_block = element(var.iz_dbsub_cidr, count.index)
    availability_zone = element(var.availability_zone, count.index)

    tags = {
      Name = "eh01-sub-izdb-${count.index + 1}"
    }
}

#Creating a internet gateway for our VPC
resource "aws_internet_gateway" "eh01_iggw_web" {
    vpc_id = aws_vpc.eh01-vpc-threetier.id

    tags = {
      Name = "eh01-iggw"
    }
}

#Create a public route table for the web subnet 
resource "aws_route_table" "eh01-rt-ezweb" {
    vpc_id = aws_vpc.eh01-vpc-threetier.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.eh01_iggw_web.id
    }

    tags = {
      Name = "eh01-rt-ezweb"
    }
}

#Associate web subnet to the public route table
resource "aws_route_table_association" "public_subnet_associate" {
    count = length(var.ez_websub_cidr)
    subnet_id = element(aws_subnet.eh01_sub_ezweb[*].id, count.index)
    route_table_id = aws_route_table.eh01-rt-ezweb.id
}

#Create a private route table for the app subnet
resource "aws_route_table" "eh01-rt-izapp" {
    vpc_id = aws_vpc.eh01-vpc-threetier.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.eh01_natgw_ezweb.id
    }
    
    tags = {
      Name = "eh01-rt-izapp"
    }

}

#Associate app subnet to the private route table
resource "aws_route_table_association" "private_appsubnet_associate" {
  count           = length(var.iz_appsub_cidr)
  subnet_id       = element(aws_subnet.eh01_sub_izapp[*].id, count.index)
  route_table_id  = aws_route_table.eh01-rt-izapp.id
}


#Create a private route table for the db subnet
resource "aws_route_table" "eh01-rt-izdb" {
    vpc_id = aws_vpc.eh01-vpc-threetier.id

    tags = {
      Name = "eh01-rt-izdb"
    }

}

#Associate db subnet to the private route table
resource "aws_route_table_association" "private_dbsubnet_associate" {
    count = length(var.iz_dbsub_cidr)
    subnet_id = element(aws_subnet.eh01_sub_izdb[*].id, count.index)
    route_table_id = aws_route_table.eh01-rt-izdb.id
}



