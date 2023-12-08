# ProfileGroupUserAddRemove
This script allows an end user to quickly add or remove an end user from your account using Mimecast's API.

## Downloading the script
Click the green button labelled `Code` and select `Download ZIP`
Extract the zip file and make sure that the `Manage-ProfileGroup.ps1` and `keys.json` file remain in the same folder

## Using the script
Using a PowerShell terminal, navigate to the folder where the script a keys files were extracted.

Before running the script, make sure you have added your API Client Secret and Client ID to the `keys.json` file.

To use the script, first run the command: 

```PowerShell
Set-ExecustionPolicy -ExecutionPolicy Undefined

```

To run the command, type the following and follow the prompts:
```powershell
.\Manage-ProfileGroup.ps1

``` 

