#Creating the 3 EC2 Instances
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "instance-01" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name = "My-machine-01"
  }
  subnet_id = var.subnet_id[0]
  security_groups = ["sg-0751072d60cd624e9", "sg-0cdee83a17e6aa4e3"]
  key_name = var.key_pair
  associate_public_ip_address = true
}

resource "aws_instance" "instance-02" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name = "My-machine-02"
  }
  subnet_id = var.subnet_id[1]
  security_groups = ["sg-0751072d60cd624e9", "sg-0cdee83a17e6aa4e3"]
  key_name = var.key_pair
  associate_public_ip_address = true
}

resource "aws_instance" "instance-03" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name = "My-machine-03"
  }
  subnet_id = var.subnet_id[1]
  security_groups = ["sg-0751072d60cd624e9", "sg-0cdee83a17e6aa4e3"]
  key_name = var.key_pair
  associate_public_ip_address = true
}

# Provisioning the application load balancer

resource "aws_lb" "project-lb" {
  name = "project-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = ["sg-0751072d60cd624e9", "sg-0cdee83a17e6aa4e3"] 
  subnets = var.subnet_id
  enable_deletion_protection = false
}

#Target groups
resource "aws_lb_target_group" "project-tg" {
  name = "project-tg"
  target_type = "instance"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 3
    unhealthy_threshold = 3
  }
}

#Create the lb listener
resource "aws_lb_listener" "project-listener" {
  load_balancer_arn = aws_lb.project-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project-tg.arn
  }
}
# Create the listener rule
resource "aws_lb_listener_rule" "Altschool-listener-rule" {
  listener_arn = aws_lb_listener.project-listener.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project-tg.arn
  }
  condition {
    path_pattern {
      values = ["/"]
    }
  }
}
 
#Attaching the target group to the load balancer

resource "aws_lb_target_group_attachment" "project-tg-attachment-01" {
  target_group_arn = aws_lb_target_group.project-tg.arn
  target_id        = aws_instance.instance-01.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "project-tg-attachment-02" {
  target_group_arn = aws_lb_target_group.project-tg.arn
  target_id        = aws_instance.instance-02.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "project-tg-attachment-03" {
  target_group_arn = aws_lb_target_group.project-tg.arn
  target_id        = aws_instance.instance-03.id
  port             = 80
}



#Create a record in route 53
resource "aws_route53_record" "site-domain" {
  zone_id = var.hosted_zone_id
  name = "test.${var.domain_name}"
  type = "A"

  alias {
    name   = aws_lb.project-lb.dns_name
    zone_id = aws_lb.project-lb.zone_id
    evaluate_target_health = true
  }
}
