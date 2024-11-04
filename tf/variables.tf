variable "domain" {
  description = "Domain of an application."
  type        = string
}

variable "environment" {
  description = "Short environment name."
  type        = string
  default     = "local"
  validation {
    condition     = contains(["local", "dev", "qa", "prod"], var.environment)
    error_message = "Invalid var.environment value. Allowed: local, dev, qa, prod."
  }
}

variable "role" {
  description = "Application Role."
  type        = string
}

variable "dice_app_path_prefix" {
  type    = string
  default = "dice-app"
  validation {
    condition     = !startswith(var.dice_app_path_prefix, "/") && length(var.dice_app_path_prefix) > 0
    error_message = "Invalid var.dice_app_path_prefix value. The prefix cannot start with / or be an empty string."
  }
}

variable "prometheus_path_prefix" {
  type    = string
  default = "prometheus"
  validation {
    condition     = !startswith(var.prometheus_path_prefix, "/") && length(var.prometheus_path_prefix) > 0
    error_message = "Invalid var.prometheus_path_prefix value. The prefix cannot start with / or be an empty string."
  }
}

variable "grafana_path_prefix" {
  type    = string
  default = "grafana"
  validation {
    condition     = !startswith(var.grafana_path_prefix, "/") && length(var.grafana_path_prefix) > 0
    error_message = "Invalid var.grafana_path_prefix value. The prefix cannot start with / or be an empty string."
  }
}

variable "dashboard_path_prefix" {
  type    = string
  default = "dashboard"
  validation {
    condition     = !startswith(var.dashboard_path_prefix, "/") && length(var.dashboard_path_prefix) > 0
    error_message = "Invalid var.dashboard_path_prefix value. The prefix cannot start with / or be an empty string."
  }
}
