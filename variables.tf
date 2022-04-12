// Globals
variable "vpc_id" {
  description = "The id of your vpc."
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster that we're deploying to."
  type        = string
}

// Load balancer configuration
variable "lb_subnets" {
  type        = list(any)
  description = "The list of subnet IDs to attach to the LB. Should be public for external LB (the default)."
}

variable "lb_security_policy" {
  description = "Security policy for the load balancer. Defaults to something interesting."
  type        = string
  default     = "ELBSecurityPolicy-FS-2018-06"
}

variable "lb_certificate_arn" {
  description = "Certificate ARN for securing HTTPS on our load balancer. We will automagically set up a redirect from 80."
  type        = string
}

variable "lb_security_groups" {
  description = "The id of the ECS cluster load balancer security group."
  type        = list(any)
}

variable "lb_internal" {
  description = "Switch for setting your LB to be internal. Defaults to false."
  type        = bool
  default     = false
}

variable "lb_secure_listener_redirect" {
  description = "Switch the secure redict from 80 to 443 on or off. On by default because this is a good idea, but you can turn it off if you have a weird edge case."
  type        = bool
  default     = "true"
}

variable "lb_access_logs_bucket" {
  description = "The bucket to log alb access logs to."
  type        = string
  default     = ""
}

variable "lb_idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application. Default: 60."
  type        = number
  default     = 60
}

variable "lb_access_logs_enabled" {
  description = "Flag for controlling alb access logs."
  type        = bool
  default     = false
}

// Health check (defaults to something sane)
variable "health_check_grace_period" {
  description = "Allows a warm up period for services that have to things like migrations etcetera."
  type        = number
  default     = 45
}

variable "health_check_interval" {
  description = "The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. Default 30 seconds."
  type        = number
  default     = 30
}

variable "health_check_path" {
  description = "The destination for the health check request."
  type        = string
  default     = "/"
}

variable "health_check_port" {
  description = "The port to use to connect with the target. Valid values are either ports 1-65536, or traffic-port. Defaults to traffic-port."
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "The protocol to use to connect with the target. Defaults to HTTP."
  type        = string
  default     = "HTTP"
}

variable "health_check_timeout" {
  description = "The amount of time, in seconds, during which no response means a failed health check. For Application Load Balancers, the range is 2 to 60 seconds and the default is 5 seconds. "
  type        = number
  default     = 5
}

variable "health_check_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3."
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering the target unhealthy ."
  type        = number
  default     = 3
}

variable "health_check_matcher" {
  description = "The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, '200,202') or a range of values (for example, '200-299'). "
  type        = string
  default     = "200"
}

// Task configuration
variable "app_name" {
  description = "The name of your app. This is used in the task configuration."
  type        = string
}

variable "app_port" {
  description = "The port you want you open on your instances. We make no assumptions here."
  type        = number
}

variable "cpu" {
  description = "The number of cpu units used by the task."
  type        = number
  default     = 256
}

variable "memory" {
  description = "The amount (in MiB) of memory used by the task."
  type        = number
  default     = 256
}

variable "container_definition" {
  description = "A container definitions JSON file."
  type        = string
}

variable "desired_task_count" {
  description = "The desired number of tasks for the service to keep running. Defaults to one."
  type        = number
  default     = 1
}

variable "service_role_arn" {
  description = "The arn of the role to associate with your ecs service."
  type        = string
}

variable "service_deployment_maximum_percent" {
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment. Defaults to 200 percent, which should be used in 99% of cases to allow for proper green/blue."
  type        = number
  default     = 200
}

variable "service_deployment_minimum_healthy_percent" {
  description = "The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that are required for the service to be considered 'healthy'."
  type        = number
  default     = 100
}

variable "launch_type" {
  description = "The launch type for the task. We assume EC2 by default."
  type        = string
  default     = "EC2"
}

variable "volumes" {
  description = "A list of definitions to attach volumes to the ECS task. Amazon does not allow empty volume names once declared, so defaulting to a dummy name if this var is left unused."
  type        = list(object({
    name      = string
    host_path = string
  }))
  default = []
}

variable "task_role_arn" {
  description = "The arn of the iam role you wish to pass to the ecs task containers."
  type        = string
  default     = ""
}

variable "ordered_placement_strategies" {
  description = "The placement strategies used for the ECS service. Defaults to the most highly available `spread` algorithm for backward compatibility. Specify a different strategy such as `binpack` for better cost-efficiency."
  type        = list(object({
    type  = string
    field = string
  }))
  default = [
    {
      type  = "spread"
      field = "attribute:ecs.availability-zone"
    },
    {
      type  = "spread"
      field = "instanceId"
    }
  ]
}

variable "circuit_breaker_enabled" {
  description = "Should we enable deployment circuit breakers? Defaults to false."
  type        = bool
  default     = false
}

variable "circuit_breaker_rollback_enabled" {
  description = "Should we enable rollback when a circuit breaker triggers? Defaults to false."
  type        = bool
  default     = false
}

variable "circuit_breaker_failure_events_enabled" {
  description = "Should we create EventBridge events for when a failure is detected by the circuit breaker? Defaults to false."
  type        = bool
  default     = false
}

variable "circuit_breaker_sns_topic_arn" {
  description = "The arn of the SNS topic to publish deployment circuit breaker failure messages to. If not provided, a SNS topic will be provided by this module."
  type        = string
  default     = null
}
