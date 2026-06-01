resource "aws_lb" "alb" {
  name               = "tf-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    aws_subnet.publicsubnetA.id,
    aws_subnet.publicsubnetB.id
  ]
  enable_deletion_protection = true
  tags = {
    Name = "tf-alb"
  }
}
resource "aws_lb_listener" "alb_li" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
 default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}
resource "aws_lb_target_group" "alb_tg" {
  name        = "terraform-alb-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"
  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200,300,301"
    }
}
resource "aws_lb_target_group_attachment" "alb_at" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.tf_ec2.id
  port             = 8080
}
