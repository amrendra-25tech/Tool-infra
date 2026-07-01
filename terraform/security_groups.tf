##############################################
# Bastion Security Group
##############################################

resource "aws_security_group" "bastion" {
  name        = "monitoring-bastion-sg"
  description = "Security Group for Bastion Host"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitoring-bastion-sg"
  }
}

##############################################
# Application Load Balancer Security Group
##############################################

resource "aws_security_group" "alb" {
  name        = "monitoring-alb-sg"
  description = "Security Group for Public ALB"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitoring-alb-sg"
  }
}

##############################################
# Private EC2 Instances Security Group
##############################################

resource "aws_security_group" "private_instances" {
  name        = "monitoring-private-sg"
  description = "Security Group for Monitoring Servers"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitoring-private-sg"
  }
}

##############################################
# EFS Security Group
##############################################

resource "aws_security_group" "efs" {
  name        = "monitoring-efs-sg"
  description = "Security Group for EFS"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitoring-efs-sg"
  }
}

##############################################
# Bastion Rules
##############################################

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  description = "SSH"
}

resource "aws_vpc_security_group_ingress_rule" "bastion_http" {
  security_group_id = aws_security_group.bastion.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  description = "Nginx"
}

##############################################
# ALB Rules
##############################################

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  description = "Grafana HTTP"
}

resource "aws_vpc_security_group_ingress_rule" "alb_loki" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 3100
  to_port     = 3100
  ip_protocol = "tcp"

  description = "Loki API"
}

##############################################
# Private Instance Rules
##############################################

# SSH from Bastion
resource "aws_vpc_security_group_ingress_rule" "private_ssh" {
  security_group_id            = aws_security_group.private_instances.id
  referenced_security_group_id = aws_security_group.bastion.id

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  description = "SSH from Bastion"
}

# Grafana from ALB
resource "aws_vpc_security_group_ingress_rule" "private_grafana" {
  security_group_id            = aws_security_group.private_instances.id
  referenced_security_group_id = aws_security_group.alb.id

  from_port   = 3000
  to_port     = 3000
  ip_protocol = "tcp"

  description = "Grafana"
}

# Loki from ALB
resource "aws_vpc_security_group_ingress_rule" "private_loki" {
  security_group_id            = aws_security_group.private_instances.id
  referenced_security_group_id = aws_security_group.alb.id

  from_port   = 3100
  to_port     = 3100
  ip_protocol = "tcp"

  description = "Loki"
}

# Prometheus (if exposed through ALB later)
resource "aws_vpc_security_group_ingress_rule" "private_prometheus" {
  security_group_id            = aws_security_group.private_instances.id
  referenced_security_group_id = aws_security_group.alb.id

  from_port   = 9090
  to_port     = 9090
  ip_protocol = "tcp"

  description = "Prometheus"
}

# Node Exporter
resource "aws_vpc_security_group_ingress_rule" "private_node_exporter" {
  security_group_id            = aws_security_group.private_instances.id
  referenced_security_group_id = aws_security_group.bastion.id

  from_port   = 9100
  to_port     = 9100
  ip_protocol = "tcp"

  description = "Node Exporter"
}

# Nginx Exporter
resource "aws_vpc_security_group_ingress_rule" "private_nginx_exporter" {
  security_group_id            = aws_security_group.private_instances.id
  referenced_security_group_id = aws_security_group.bastion.id

  from_port   = 9113
  to_port     = 9113
  ip_protocol = "tcp"

  description = "Nginx Exporter"
}

##############################################
# EFS Rules
##############################################

resource "aws_vpc_security_group_ingress_rule" "efs_nfs" {
  security_group_id            = aws_security_group.efs.id
  referenced_security_group_id = aws_security_group.private_instances.id

  from_port   = 2049
  to_port     = 2049
  ip_protocol = "tcp"

  description = "NFS from Private Instances"
}