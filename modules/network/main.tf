
resource "terraform_data" "network_validation" {
  lifecycle {
    precondition {
      condition = (
        length(distinct(concat(
          var.public_subnet_cidrs,
          var.private_subnet_cidrs
        ))) ==
        length(concat(
          var.public_subnet_cidrs,
          var.private_subnet_cidrs
        ))
      )
      error_message = "Public and private subnet CIDR blocks must all be unique."
    }
  }
}

# Create the Virtual Private Cloud
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name        = "${var.name}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# Create an Internet Gateway for public connectivity
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name        = "${var.name}-igw"
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# Create public subnets
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name        = "${var.name}-public-${count.index + 1}"
    Environment = var.environment
    Type        = "Public"
    ManagedBy   = "Terraform"
  })
}

# Create private subnets
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name        = "${var.name}-private-${count.index + 1}"
    Environment = var.environment
    Type        = "Private"
    ManagedBy   = "Terraform"
  })
}

# Create the public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name        = "${var.name}-public-rt"
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# Route public internet traffic through the Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create the private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name        = "${var.name}-private-rt"
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
