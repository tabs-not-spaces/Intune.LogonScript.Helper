# Intune LogonScript Helper

![Multi User Example](https://i.imgur.com/1Cl1ObR.gif)

## Summary

A solution to help you solve a fairly simple task - giving access to On-prem file shares and printers based on security group membership of a user.

Previously this was achievable using LDAP queries on devices that were domain joined, or even simpler - with Group Policy.

Now with the rapid push to cloud managed end user devices, what most have taken for granted as a simple endeavour has become a major road block to completing modern management projects.

WIth this solution, you can, with very minimal ongoing maintenance, have the benefits of cloud based modern management AND still maintain on-prem file shares and print queues.

Here's how the solution works at a high level.

![sequence diagram](/sequencediagram.png)

Please note: the solution contained within this repository is only the function app (or the "middleware") of the process workflow outlined in the diagram above. This gives you the ability to programmatically understand what resources a user *should* get access to - It's up to you to build out the actual logon script that handles that data and does the local mapping of drives and printers... if you don't understand how to do that, begin there and then come back to this project.

## Configuration

The solution in this repository requires a little bit of configuration - namely, building your drivemaps.json file, configuring an AAD application and creating and publishing a function app.

### drivemaps.json

Arguable the heart of this solution, the [drivemaps.json](https://github.com/tabs-not-spaces/Intune.LogonScript.Helper/blob/e8d41abf7787b9f41aeb7d0937ac852bfee693d6/function-app/aad-sec-grp-qry/drivemaps.json) file contains the logic of your logon script solution. Use the contained file as a reference to build your own based on your business requirements.

### AAD app registration

- Create an AAD application with the following Graph API permissions:

| Permission Name | Permission Scope |
|--- | --- |
| Directory.Read.All | Application|
| Group.Read.All | Application |
| User.Read | Delegated |
| User.Read.All | Application |

- Capture the application ID and generate a client secret.

### Function app

- Create a function app using PowerShell Core as the runtime stack.
- Add the following application settings to the configuration of the function app:

| Setting Name | Setting Value |
| --- | --- |
| CLIENT_ID | The application id of your AAD App |
| CLIENT_SEC | The client secret of your AAD App |
| RES_URL | https://graph.microsoft.com |
| TENANT_ID | The AAD tenant ID |

- Create a new function inside your newly created function app.
- Replace the sample code with the contents of [run.ps1](https://github.com/tabs-not-spaces/Intune.LogonScript.Helper/blob/e8d41abf7787b9f41aeb7d0937ac852bfee693d6/function-app/aad-sec-grp-qry/run.ps1)
- Copy your modified drivemaps.json file to the root of the function.
- Save the changes and make note of the function URL

## Using the solution

Below is some sample code to show how to use the solution:

``` PowerShell
$uri = "http://yourfunctionappurl.azurewebsites.net" #replace with your function url
$user = whoami /upn
$query = "$uri&user=$user"
$res = Invoke-RestMethod -Method Get -Uri $query
Write-Host "Hey $user.." -ForegroundColor Yellow
Write-Host "We found some drives you should have access to.." -ForegroundColor Yellow
foreach ($d in $res.drives) {
    "drive letter: $($d.driveletter) | network path: $($d.uncPath)"
    # put your business logic in here to do something with the results.
}
Write-Host "`nWe found some printers you should have access to.." -ForegroundColor Yellow
foreach ($p in $res.printers) {
    "print queue: $($p.printer) | print server: $($p.server)"
    # put your business logic in here to do something with the results.
}
Write-Host "--`n"
```

## CI-CD Pipelines

Contained in this repository is a copy of my Azure-Pipelines.yml file to assist you with implementing a CI-CD build / deployment pipeline.
You will need to review and modify to use in your environment.

The pipeline also makes use of application slots to allow testing and validation before pushing to production. [Read this for further info.](https://docs.microsoft.com/en-us/azure/app-service/deploy-staging-slots#which-settings-are-swapped)
