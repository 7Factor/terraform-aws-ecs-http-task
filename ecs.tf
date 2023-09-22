data "aws_ecs_cluster" "target_cluster" {
  cluster_name = var.cluster_name
}

resource "aws_ecs_task_definition" "main_task" {
  family                   = "${var.app_name}-tsk"
  requires_compatibilities = [var.launch_type]
  network_mode             = var.launch_type == "FARGATE " ? "awsvpc" : var.network_mode
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = var.container_definition

  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn

  dynamic "volume" {
    for_each = [for v in var.volumes : {
      name      = v.name
      host_path = v.host_path
    }]

    content {
      name      = volume.value.name
      host_path = volume.value.host_path
    }
  }

  dynamic "volume" {
    for_each = [for v in var.efs_volumes : {
      name                    = v.name
      host_path               = v.host_path
      file_system_id          = v.file_system_id
      root_directory          = v.root_directory
      transit_encryption      = v.transit_encryption
      transit_encryption_port = v.transit_encryption_port

      authorization_config = v.access_point_id == null && v.iam == null ? [] : [{
        access_point_id = v.access_point_id
        iam             = v.iam
      }]
    }]

    content {
      name      = volume.value.name
      host_path = volume.value.host_path

      efs_volume_configuration {
        file_system_id          = volume.value.file_system_id
        root_directory          = volume.value.root_directory
        transit_encryption      = coalesce(volume.value.transit_encryption, "DISABLED")
        transit_encryption_port = volume.value.transit_encryption_port

        dynamic "authorization_config" {
          for_each = [for a in volume.value.authorization_config : {
            access_point_id = a.access_point_id
            iam             = a.iam
          }]

          content {
            access_point_id = authorization_config.value.access_point_id
            iam             = authorization_config.value.iam
          }
        }
      }
    }
  }
}

resource "aws_ecs_service" "main_service" {
  name                               = "${var.app_name}-svc"
  task_definition                    = aws_ecs_task_definition.main_task.arn
  cluster                            = data.aws_ecs_cluster.target_cluster.id
  desired_count                      = var.desired_task_count
  iam_role                           = var.additional_lb_target_groups > 0 ? null : var.service_role_arn
  launch_type                        = var.launch_type
  deployment_maximum_percent         = var.service_deployment_maximum_percent
  deployment_minimum_healthy_percent = var.service_deployment_minimum_healthy_percent
  health_check_grace_period_seconds  = var.health_check_grace_period

  deployment_circuit_breaker {
    enable   = var.circuit_breaker_enabled
    rollback = var.circuit_breaker_rollback_enabled
  }

  dynamic "network_configuration" {
    for_each = [for n in var.network_configurations : {
      subnets          = n.subnets
      security_groups  = n.security_groups
      assign_public_ip = n.assign_public_ip
    }]

    content {
      subnets          = network_configuration.value.subnets
      security_groups  = network_configuration.value.security_groups
      assign_public_ip = network_configuration.value.assign_public_ip
    }
  }

  load_balancer {
    container_name   = var.app_name
    container_port   = var.app_port
    target_group_arn = aws_lb_target_group.lb_targets.arn
  }

  dynamic "load_balancer" {
    for_each = range(var.additional_lb_target_groups)
    content {
      container_name   = var.app_name
      container_port   = var.app_port
      target_group_arn = aws_lb_target_group.additional_lb_targets[load_balancer.key].arn
    }
  }

  depends_on = [aws_lb.app_lb]

  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategies
    content {
      type  = ordered_placement_strategy.value.type
      field = ordered_placement_strategy.value.field
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
      # this is critical to include, to prevent the service from being rebuilt on every deploy
      # thus causing the service to become unavailable during a deploy
      capacity_provider_strategy
    ]
  }
}

data "aws_ecs_service" "main_service" {
  cluster_arn  = data.aws_ecs_cluster.target_cluster.arn
  service_name = aws_ecs_service.main_service.name
}
