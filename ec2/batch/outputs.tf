# EC2 Complete
output "ec2_complete_id" {
  description = "The ID of the instance"
  value       = module.ec2_complete.id
}

output "ec2_complete_arn" {
  description = "The ARN of the instance"
  value       = module.ec2_complete.arn
}

output "ec2_complete_instance_state" {
  description = "The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped`"
  value       = module.ec2_complete.instance_state
}