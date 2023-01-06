
# This powershell script will retrieve the callback URL for a Logic App HTTP workflow trigger
param(
    [Parameter(Mandatory=$true)]
    $subscription,
    [Parameter(Mandatory=$true)]
    $resourceGroupName,
    [Parameter(Mandatory=$true)]
    $logicAppName,
    [Parameter(Mandatory=$true)]
    $workflowName
)

$logicAppInfo = az rest --method post --uri https://management.azure.com/subscriptions/$subscription/resourceGroups/$resourceGroupName/providers/Microsoft.Web/sites/$logicAppName/hostruntime/runtime/webhooks/workflow/api/management/workflows/$workflowName/triggers/manual/listCallbackUrl?api-version=2018-11-01 | ConvertFrom-Json
$webhook=$logicAppInfo.value
az webapp config appsettings set -g $resourceGroupName -n $logicAppName --settings LOGIC_APP_WEBHOOK=$webhook



