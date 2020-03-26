## ************************************************************************************************
## This PowerShell script s part of a social listening tool developed by Niall Moran, Micrososft
## See https://github.com/niallermoran/sociallistening for more information
## This Powershell script should be run to setup the new Azure environment
## ************************************************************************************************

## variables to be updated
$subname = "MTC Dublin Azure - Azure Stack"
$location = "North Europe"
$resourcegroupname = "SocialListening"
$sqlservername = "social-listening-sql-server" ## It can only be made up of lowercase letters 'a'-'z', the numbers 0-9 and the hyphen. The hyphen may not lead or trail in the name.
$sqldbname = "social-listening-sql-db"

## for error tracking
$ErrorActionPreference = "SilentlyContinue" # change to SilentlyContinue once completed

## ARM template parameters
$text_analytics_domain = "textanalytics-niall"  ## this needs to be globally unique or you will get an error
$text_analytics_name = "textanalytics" 

$connections_sql_name = "sql"
$connections_twitter_name = "twitter"
$connections_cognitiveservicestextanalytics_name = "textanalytics"

## dynamic variables
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

## you will need to run this for the first time to connect to the Azure APIs
    ## Connect-AzAccount

## set the subscription context
    echo "Setting the subscription to: $subname"
    Set-AzContext -Subscription $subname | Out-Null
    $subscription = Get-AzSubscription -SubscriptionName $subname
    $subid = $subscription.Id

## check if the resource group exists
    echo "Creating resource group: $resourcegroupname"

    Get-AzResourceGroup -Name $resourcegroupname -ErrorVariable notPresent -ErrorAction $ErrorActionPreference 

    if ($notPresent)
    {
        ## create a new Azure resource group.
        New-AzResourceGroup -Name $resourcegroupname  -Location $location -ErrorAction $ErrorActionPreference 

        echo "Resource group $resourcegroupname created!"
    }
    else
    {
        ##$userg = Read-Host "The resource group $resourcegroupname already exists. Do you want to use it?" 
     
        Write-Host "The resource group $resourcegroupname already exists. Do you want to use it? (Default is No)" -ForegroundColor Yellow 
        $Readhost = Read-Host " ( y / n ) " 
        Switch ($ReadHost) 
         { 
           N {Exit} 
           Default {Exit} 
           Y
           {
            echo "Continuing with resource group $resourcegroupname"
           }
         } 

    }



##create the logic app connections required
    $templateFileCN = "$scriptDir\ARM\CreateLogicAppConnections\template.json"

    ## create the correct parameter objeect to pass when creating the resources
    $paramObjectConnections = @{
        'connections_sql_name' = $connections_sql_name
        'connections_twitter_name'  = $connections_twitter_name
        'connections_cognitiveservicestextanalytics_name' = $text_analytics_name
        'connections_cognitiveservicestextanalytics_key' = 'key'
        'connections_cognitiveservicestextanalytics_url' = 'https://textanalytics-niallmoran.cognitiveservices.azure.com/'
        'connections_sql_server' = $sqlservername
        'connections_sql_dbname' = $sqldbname
    }

    ## create the service
    echo "Creating the logic app connections"
#    New-AzResourceGroupDeployment -Name logicappconnections -ResourceGroupName $resourcegroupname -TemplateFile $templateFileCN -TemplateParameterObject $paramObjectConnections -Debug


##end

## create the logic apps
    $templateFileLogic = "$scriptDir\ARM\CreateLogicApps\template.json"

    ## create the correct parameter object to pass when creating the resources
    $paramObjectLogicApps = @{
        'workflows_bing_locations_name' = 'bing_locations_logic_app'
        'workflows_social_listening_twitter_name'  = 'twitter_logic_app'
        'connections_sql_externalid'  = "/subscriptions/" + $subid + "/resourceGroups/" + $resourcegroupname +  "/providers/Microsoft.Web/connections/" + $connections_sql_name
        'connections_cognitiveservicestextanalytics_externalid'  = "/subscriptions/" + $subid + "/resourceGroups/" + $resourcegroupname +  "/providers/Microsoft.Web/connections/" + $connections_cognitiveservicestextanalytics_name
        'connections_twitter_externalid'  = "/subscriptions/" + $subid + "/resourceGroups/" + $resourcegroupname +  "/providers/Microsoft.Web/connections/" + $connections_twitter_name
    }

    ## create the logic apps
    echo "Creating the Logic apps"        
    New-AzResourceGroupDeployment -Name logicapps -ResourceGroupName $resourcegroupname -TemplateFile $templateFileLogic -TemplateParameterObject $paramObjectLogicApps -Debug

    
##end
