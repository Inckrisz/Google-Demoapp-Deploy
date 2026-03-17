output "alb_id" {
  description = "Id of Application Load Balancer"
  value = aws_lb.test.id
}