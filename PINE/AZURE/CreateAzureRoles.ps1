Get-AzProviderOperation "Microsoft.Compute/virtualMachines/*" | FT OperationName, Operation, Description –AutoSize 
$sub=Get-AzSubscription -SubscriptionName "Azure Pass - Sponsorship"
$role=Get-AzRoleDefinition "Virtual Machine Contributor"
$role.actions
$role.Id=$null
$role.Name="Virtual Machine Operator"
$role.Description = "He Can monitor and restart virtual machines."
$role.Actions.Remove("Microsoft.Compute/virtualMachines/*")
$role.Actions.Remove("Microsoft.Compute/virtualMachineScaleSets/*")
$role.Actions.Add("Microsoft.Compute/virtualMachines/read")
$role.Actions.Add("Microsoft.Compute/virtualMachines/start/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/restart/action")
$role.AssignableScopes.Clear()
$role.AssignableScopes.Add("/subscriptions/$($sub.id)")
New-AzRoleDefinition -Role $role