# EC2 Complete
output "ec2_batch_id" {
  description = "The ID of the instance"
  value       = module.ec2_batch.id
}

output "ec2_batch_arn" {
  description = "The ARN of the instance"
  value       = module.ec2_batch.arn
}

output "ec2_batch_instance_state" {
  description = "The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped`"
  value       = module.ec2_batch.instance_state
}