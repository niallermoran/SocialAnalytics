## ************************************************************************************************
## This PowerShell script s part of a social listening tool developed by Niall Moran, Micrososft
## See https://github.com/niallermoran/sociallistening for more information
## This Powershell script should be run to setup the new Azure environment
## ************************************************************************************************

## get the dynamic variables from the file SetupVariables.json located in the same folder as this script
## this variables file is not included in the GitHub repository and should be created lcoally and updated
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$VariablesFile = $scriptDir + "\SetupVariables.json"
$VariablesJsonObject = Get-Content $VariablesFile | ConvertFrom-Json


## variables to be updated
$subname = $VariablesJsonObject.subname
$location = $VariablesJsonObject.location
$sqllocation = $VariablesJsonObject.sqllocation
$resourcegroupname = $VariablesJsonObject.resourcegroupname
$sqlservername = $VariablesJsonObject.sqlservername ## It can only be made up of lowercase letters 'a'-'z', the numbers 0-9 and the hyphen. The hyphen may not lead or trail in the name.
$sqldbname = $VariablesJsonObject.sqldbname
$bing_maps_key = $VariablesJsonObject.bing_maps_key
$twitter_search_term = $VariablesJsonObject.twitter_search_term
$text_analytics_domain = $VariablesJsonObject.text_analytics_domain  ## this needs to be globally unique or you will get an error
$text_analytics_name = $VariablesJsonObject.text_analytics_name
$text_analytics_tier = $VariablesJsonObject.text_analytics_tier


## for error tracking
$ErrorActionPreference = "SilentlyContinue" # change to SilentlyContinue once completed

 
## dynamic variables

$connections_sql_name = "sql"
$connections_twitter_name = "twitter"
$connections_cognitiveservicestextanalytics_name = "textanalytics"

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

## create sql server and database

    $templateFileSQLServer = "$scriptDir\ARM\CreateSQLDatabase\template.json"

    $adminUser = Read-Host -Prompt "Enter the SQL server administrator username"
    $adminPassword = Read-Host -Prompt "Enter the SQl server administrator password" -AsSecureString

    ## create the correct parameter object to pass when creating the resources
    $paramObject = @{
        'dbName' = $sqldbname
        'serverName' = $sqlservername
        'location' = $sqllocation
    }

    echo "Creating the sql server"

    New-AzResourceGroupDeployment -Name "sqlservertemplate" -ResourceGroupName $resourcegroupname  -TemplateFile $templateFileSQLServer -TemplateParameterObject $paramObject -administratorLogin $adminUser -administratorLoginPassword $adminPassword -ErrorVariable failed -ErrorAction $ErrorActionPreference 

    if( $failed )
    {
        echo "There was a problem creating the SQL resources !"  + $failed
        Cleanup
    }
    else
    {
        echo "SQL server and database service created"        
    }

##create the text analytics cognitive service

    $templateFileTA = "$scriptDir\ARM\CreateTextAnalytics\template.json"
    
    ## create the correct parameter objeect to pass when creating the resources
    $paramObject = @{
        'name' = $text_analytics_name
        'text_analytics_domain_name' = $text_analytics_domain
        'text_analytics_tier' = $text_analytics_tier
    }
    
    ## create the service
    echo "Creating the text analytics service"
   
    New-AzResourceGroupDeployment -Name "textanalyticstemplate" -ResourceGroupName $resourcegroupname -TemplateFile $templateFileTA -TemplateParameterObject $paramObject -ErrorVariable failed -ErrorAction $ErrorActionPreference
    
    if( $failed )
    {
        echo "There was a problem creating the text analytics service !"  + $failed
        Cleanup
    }
    else
    {
        echo "Text analytics service created"        
    }

##end

##create the logic app connections required
    $templateFileCN = "$scriptDir\ARM\CreateLogicAppConnections\template.json"

    ## create the correct parameter objeect to pass when creating the resources
    $paramObjectConnections = @{
        'connections_sql_name' = $connections_sql_name
        'connections_twitter_name'  = $connections_twitter_name
        'connections_cognitiveservicestextanalytics_name' = $connections_cognitiveservicestextanalytics_name
        'connections_sql_server' = $sqlservername + '.database.windows.net'
        'connections_sql_dbname' = $sqldbname
    }

    ## create the service
    echo "Creating the logic app connections"
    New-AzResourceGroupDeployment -Name logicappconnectionstemplate -ResourceGroupName $resourcegroupname -TemplateFile $templateFileCN -TemplateParameterObject $paramObjectConnections -ErrorVariable failed -ErrorAction $ErrorActionPreference

    if( $failed )
    {
        echo "There was a problem creating the connections!"  + $failed
        Cleanup
    }
    else
    {
        echo "Logic app connections created"        
    }
    

##end


## create the bing logic apps
    $templateFileLogic = "$scriptDir\ARM\CreateLogicApps\template_binglocations.json"

    ## create the correct parameter object to pass when creating the resources
    $paramObjectLogicApps = @{
        'workflows_bing_locations_logic_app_name' = 'bing_locations_logic_app'
        'connections_sql_externalid'  = "/subscriptions/" + $subid + "/resourceGroups/" + $resourcegroupname +  "/providers/Microsoft.Web/connections/" + $connections_sql_name
        'bing_api_key' = $bing_maps_key
    }

    ## create the logic apps
    echo "Creating the Bing Location search Logic app"        
    New-AzResourceGroupDeployment -Name binglogicappstemplate -ResourceGroupName $resourcegroupname -TemplateFile $templateFileLogic -TemplateParameterObject $paramObjectLogicApps -ErrorVariable failed -ErrorAction $ErrorActionPreference

    if( $failed )
    {
        echo "There was a problem creating the logic app!"  + $failed
        Cleanup
    }
    else
    {
        echo "Logic apps created"        
    }

    echo "Finished Everything!"  

##end

## create the phrase extraction logic apps
     $templateFileLogic = "$scriptDir\ARM\CreateLogicApps\template_phraseextraction.json"

    ## create the correct parameter object to pass when creating the resources
    $paramObjectLogicApps = @{
        'workflows_extract_phrase_logicapp_name' = 'phrase_extraction_logic_app'
        'connections_sql_externalid'  = "/subscriptions/" + $subid + "/resourceGroups/" + $resourcegroupname +  "/providers/Microsoft.Web/connections/" + $connections_sql_name
        'connections_textanalytics_name' = $connections_cognitiveservicestextanalytics_name
        'connections_textanalytics_externalid'  = "/subscriptions/" + $subid + "/resourceGroups/" + $resourcegroupname +  "/providers/Microsoft.Web/connections/" + $connections_cognitiveservicestextanalytics_name
    }

    ## create the logic apps
    echo "Creating the Phrase Extraction Logic apps"        
    New-AzResourceGroupDeployment -Name phraselogicappstemplate -ResourceGroupName $resourcegroupname -TemplateFile $templateFileLogic -TemplateParameterObject $paramObjectLogicApps -ErrorVariable failed -ErrorAction $ErrorActionPreference

    if( $failed )
    {
        echo "There was a problem creating the phrase extraction logic apps!"  + $failed
        Cleanup
    }
    else
    {
        echo "Logic apps created"        
    }

    echo "Finished Everything!"  

##end

## create the sentiment logic app
      $templateFileLogic = "$scriptDir\ARM\CreateLogicApps\template_sentiment.json"

    ## create the correct parameter object to pass when creating the resources
    $paramObjectLogicApps = @{
        'workflows_sentiment_logic_app_name' = 'sentiment_logic_app'
        'connections_sql_externalid'  = "/subscriptions/" + $subid + "/resourceGroups/" + $resourcegroupname +  "/providers/Microsoft.Web/connections/" + $connections_sql_name
        'connections_textanalytics_externalid'  = "/subscriptions/" + $subid + "/resourceGroups/" + $resourcegroupname +  "/providers/Microsoft.Web/connections/" + $connections_cognitiveservicestextanalytics_name
    }


    ## create the logic app
    echo "Creating the sentiment analysis Logic apps"        
    New-AzResourceGroupDeployment -Name sentimentlogicappstemplate -ResourceGroupName $resourcegroupname -TemplateFile $templateFileLogic -TemplateParameterObject $paramObjectLogicApps -ErrorVariable failed -ErrorAction $ErrorActionPreference

    if( $failed )
    {
        echo "There was a problem creating the sentiment logic app!"  + $failed
        Cleanup
    }
    else
    {
        echo "Logic apps created"        
    }

    echo "Finished Everything!"  

##end

## create the twitter seacrh logic app
    $templateFileLogic = "$scriptDir\ARM\CreateLogicApps\template_twitter.json"

    ## create the correct parameter object to pass when creating the resources
    $paramObjectLogicApps = @{
        'workflows_twitter_logic_app_name' = 'twitter_seach_logicapp'
        'connections_sql_externalid'  = "/subscriptions/" + $subid + "/resourceGroups/" + $resourcegroupname +  "/providers/Microsoft.Web/connections/" + $connections_sql_name
        'connections_twitter_externalid'  = "/subscriptions/" + $subid + "/resourceGroups/" + $resourcegroupname +  "/providers/Microsoft.Web/connections/" + $connections_twitter_name
        'twitter_search_term' = $twitter_search_term
    }

    ## create the logic apps
    echo "Creating the Twitter search Logic apps"        
    New-AzResourceGroupDeployment -Name logicappstemplate -ResourceGroupName $resourcegroupname -TemplateFile $templateFileLogic -TemplateParameterObject $paramObjectLogicApps -ErrorVariable failed -ErrorAction $ErrorActionPreference


    if( $failed )
    {
        echo "There was a problem creating the twitter seach logic app!"  + $failed
        Cleanup
    }
    else
    {
        echo "Logic apps created"        
    }

    echo "Finished Everything!"  

##end

## Remove-AzResourceGroup -Name $resourcegroupname

## cleanup function
    function Cleanup
    {

        Write-Host "Do you want to remove the resource group $resourcegroupname or continue (Default is No to not delete and continue)" -ForegroundColor Yellow 
        $Readhost = Read-Host " ( y / n ) " 
        Switch ($ReadHost) 
         { 
           N {} 
           Default {} 
           Y
           {
               echo "Cleaning up..."

                ## delete the resource group
                Remove-AzResourceGroup -Name $resourcegroupname -Confirm -ErrorVariable failed -ErrorAction $ErrorActionPreference | Out-GridView

                if( $failed )
                {
                    echo "There was a problem cleaning up the resource group $resourcegroupname, please do this manually in the Azure portal to avoid charges!" 
                }
                else
                {
                    echo "Finished!"        
                }

                Exit

           }
         } 
    }


## debugging
    ## Get-AzLog -CorrelationId '7117e1b4-4136-4a10-8282-96ed413b3f4b' -DetailedOutput