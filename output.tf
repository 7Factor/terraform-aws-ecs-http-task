output "lb_hostname" {
  value = module.app_lb.hostname
}

output "lb_name" {
  value = module.app_lb.name
}

output "lb_arn" {
  value = module.app_lb.arn
}

output "lb_arn_suffix" {
  value = module.app_lb.arn_suffix
}

output "lb_secure_listener" {
  value = module.app_lb.secure_listener_arn
}

output "lb_target_group_name" {
  value = aws_lb_target_group.lb_targets.name
}

output "health_check_path" {
  value = var.health_check_path
}

output "lb_zone_id" {
  value = module.app_lb.zone_id
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.main_task.arn
}

output "service_name" {
  value = aws_ecs_service.main_service.name
}
