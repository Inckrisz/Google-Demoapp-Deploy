variable "family" {
  description = "Name of the task definition"
  type = string
}

variable "containers" {
  description = "Json for the container(s)"
  type = list(any)
}

variable "execution_role_arn" {
  
}

variable "task_role_arn" {
  
}

# example jsonencode([
#     {
#       name      = var.name
#       image     = var.image
#       cpu       = var.cpu
#       memory    = var.memory
#       essential = true
#       portMappings = [
#         {
#           containerPort = var.containerPort
#           hostPort      = var.hostPort
#         }
#       ]
#     },
#     {
#       name      = var.second_name
#       image     = var.second_image
#       cpu       = var.second_cpu
#       memory    = var.second_memory
#       essential = false
#       portMappings = [
#         {
#           containerPort = var.second_containerPort
#           hostPort      = var.second_hostPort
#         }
#       ]
#     }
#   ])