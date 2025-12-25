#---------------------------------------------------------------------------------------------#
# Módulo para configurar uma VPC com sub-redes públicas e privadas, gateway de internet e NAT Gateway
#---------------------------------------------------------------------------------------------#


data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  # Habilita resolução de DNS e hostnames no VPC para permitir private DNS em VPC endpoints
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.project_common_tags, {
    Name = "${var.vpc_name}-VPC"
  })
}

resource "aws_subnet" "subnet_private" {
  count      = 2
  depends_on = [aws_vpc.main]

  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.private_subnet_cidr, 1, count.index)

  tags = merge(var.project_common_tags, {
    Name = "${var.vpc_name}-private-subnet"
  })
}

resource "aws_subnet" "subnet_public" {
  count      = 1
  depends_on = [aws_vpc.main]

  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr

  tags = merge(var.project_common_tags, {
    Name = "${var.vpc_name}-public-subnet"
  })
}

# Gateway de Internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.project_common_tags, {
    Name = "${var.vpc_name}-igw"
  })
}

# Tabela de rotas públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.project_common_tags, {
    Name = "${var.vpc_name}-public-rt"
  })
}

# Associação da tabela de rotas públicas com a sub-rede pública
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.subnet_public[0].id
  route_table_id = aws_route_table.public.id
}

# Rota para o tráfego de internet na tabela de rotas públicas
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Elastic IP para o NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.project_common_tags, {
    Name = "${var.vpc_name}-nat-eip"
  })
}

# NAT Gateway na sub-rede pública
resource "aws_nat_gateway" "nat" {
  depends_on = [aws_internet_gateway.igw]

  allocation_id = aws_eip.nat.allocation_id
  subnet_id     = aws_subnet.subnet_public[0].id

  tags = merge(var.project_common_tags, {
    Name = "${var.vpc_name}-nat-gateway"
  })
}

# Tabela de rotas privadas
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.project_common_tags, {
    Name = "${var.vpc_name}-private-rt"
  })
}

# Associação da tabela de rotas privadas com a sub-rede privada
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_association" {
  count          = length(aws_subnet.subnet_private)
  subnet_id      = aws_subnet.subnet_private[count.index].id
  route_table_id = aws_route_table.private.id
}