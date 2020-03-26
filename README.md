# SocialAnalytics
A social analytics tool based on Azure logic apps, Azure sql database and PowerBI

## Steps to Setup

### Create Azure Resources
The Azure resources are created using a PowerShell script and ARM json templates. Please make sure you maintain the folder structure from GitHub otherwise the script will fail to run.
 - Open the PowerShell Script using your editor of choice
 - Update the variables at the start of the script. Pay attention to some of the notes in comments
 - Run the script, paying attention to any inputs asked. These may be security credentials so please remember them.
 - Make sure the PowerShell script has run successfully, before continuing

### Update SQL Schema
Now that we all of our Azure resources, including the SQL Database, we now need to update the database schema. [TODO: update PowerShell to incorporate this step]
- Go to the Azure portal and find the resource group created from the previous step. You should see quite a few resources within this group including a SQL server, a sql database, a number of API connections and a umber of logic apps.
- Click on the SQL database resource
- From the resource menu click 'Query Editor' and login using the credentials used in the previous step.
- If this step fails due to a firewall issue then copy the IP address given and click 'Set server Firewall'
- Create a new firewall rule for this IP address and click save. Then close this blade to reveal the previous Query Editor blade.
- Click OK and this time the query editor should open successfully.
- Copy the contents of 'generatedbobjects.sql' found in the 'Data\AzureSQLDatabase' folder and run.
- Ensure the query runs without any errors. You can close the query editor window without saving.
### Authenticate the Connections
As part of creating the Azure resources step a number of API connections were created. You now need to authenticate each of these.
- Return to the resource group created in previous steps.
- Open the twitter API connection, the status should be 'unauthenticated'
- Click on 'Edit API Connection'
- Click on 'Authorize' and connect a twitter account.
- Click 'Save'
- Return to the resource group created in previous steps.
- Open the Text Analytics cognitive service and make note of 'Key1' and 'Endpoint'
- Return to the resource group created in previous steps.
- Open the Text Analytics API connection, the status should be 'error'
- Click on 'Edit API Connection'
- Enter the account key and Site Url.
- Click 'Save'
- Return to the resource group created in previous steps.
- Open the SQL api connection
- Click on 'Edit API Connection'
- Enter the username and password that you used during the PowerShell script execution
- Click 'Save' [NOTE: (26Mar2020) You may need to click 'Save' twice until you see the notification to indicate it has been saved]
### Update Logic Apps
Now that everything is setup, our Logic Apps, should now work correctly, but they will be disabled.
- Return to the resource group created in previous steps.
- Open the Bing locations logic app and click the 'Enable' button
- Now click the 'Edit' button and then 'Run'
- Stay in the editor and wait to see the run complete successfully
- Return to the resource group created in previous steps.
- Open the twitter logic app and click the 'Enable' button.
- Now click the 'Edit' button and then 'Run' or 'Save' and then 'Run' if 'Run' is not immediately available.
- Stay in the editor and wait to see the run complete successfully
### Test Everything
- To test everything is working query the sql database by reviewing the results of each of the views: viewLocation, viewTweets and view Phrases
- Within viewLocations you should start to see records with BingLocation populated. This won't be the case for all records as users can add whatever location they want in twitter.
- After some time check the run history of both logic apps to ensure they are performing correctly.

### Setup the PowerBI Desktop report
- Open the pbix file located under the Reports folder
- second
- third

### Common Issues
- When running the twitter logic app if you get an error at the search tweets step, just click in and click 'change connection' then select the twitter connection and rerun

  