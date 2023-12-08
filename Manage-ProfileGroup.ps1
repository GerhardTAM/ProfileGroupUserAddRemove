#####################Connection################################
#Auth file

$config = Get-Content -Path ".\keys.json" | ConvertFrom-Json


$clientId = $config.client_id
$clientSecret = $config.client_secret
# ID for/directory/find-groups EndPoint
$id = ""
#EmailAddress Array list for directory/get-group-members EndPoint
$emailAddresses = @()
#Taking user input from delete question
$deleteInput = ""

Function Get-Token ($clientId, $clientSecret) {
    $tokenUrl = "https://api.services.mimecast.com/oauth/token"

    $body = @{
        client_id     = $clientId
        client_secret = $clientSecret
        grant_type    = "client_credentials"
    }

    $response = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $body -ContentType "application/x-www-form-urlencoded"

    return "$($response.token_type) $($response.access_token)"
}

$token = Get-Token -clientId $clientId -clientSecret $clientSecret

############################find-groups#############################################
#Taking user input for Group Name

$input =  Read-Host -Prompt 'Enter Group Name:'

# Requesting to find group

$requestUrl = "https://api.services.mimecast.com/api/directory/find-groups"

# The body part
$requestBody = @{
    data = @(
        @{
            query = $input
            source  = "cloud"
        }
    )
} | ConvertTo-Json

$requestHeaders = @{
    "Authorization" = $token
    "Accept"        = "application/json"
    "Content-Type"  = "application/json"
}

$response = Invoke-RestMethod -Uri $requestUrl -Method POST -Headers $requestHeaders -Body $requestBody

#Converting the response to json

$response | ConvertTo-Json -Depth 32 | Write-Host

#Just getting the ID number via foreach loop  from Folders object and storing in ID variable 

foreach($folder in $response[0].data.folders){
  
  $id = $folder.id
}

############################find-group members#############################################
# Requesting to find group member
$requestUrl = "https://api.services.mimecast.com/api/directory/get-group-members"
# The body part
$requestBody = @{
    data = @(
        @{
           id = $id
            
        }
    )
} | ConvertTo-Json

$requestHeaders = @{
    "Authorization" = $token
    "Accept"        = "application/json"
    "Content-Type"  = "application/json"
}

$response = Invoke-RestMethod -Uri $requestUrl -Method POST -Headers $requestHeaders -Body $requestBody
#Converting to Json
$response | ConvertTo-Json -Depth 32 | Write-Host

#Just getting the email address number via foreach loop from GroupMembers object and storing in emailaddress variable as a report
$reportContent = ""

foreach($folder in $response[0].data.groupMembers){
 
  $emailAddress = $folder.emailAddress
    $emailAddresses += $emailAddress
}


do {
    # Prompts the user for input
    $emailaction = Read-Host "Please enter your email address:"

    # Definse a regular expression pattern to validate email format
    $emailPattern = "^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"

    # Check if the user input matches the email pattern
    if ($emailaction -match $emailPattern) {
        Write-Host "Email address is valid: $emailaction"
        $isValid = $true
    } else {
        Write-Host "Invalid email address format. Please try again."
        $isValid = $false
    }
} while (-not $isValid)

    # This checks the email address typed exist in the result
   $results = $emailAddresses | Where-Object { $_ -eq $emailaction }

   #This gives user the option to delete or add based on the result
  if ($results) {
    Write-Host "********Email Found********: $results"
    Write-Host "Would you like to delete $results::"
    $deleteInput = Read-Host -Prompt '(Y/N)'
} else {
    Write-Host "********Email Not Found*********"
    Write-Host "Would you like to add" $emailaction "to the group?::"
    $NewEmailAddInput = Read-Host -Prompt '(Y/N)'

   }
############################Remove-grou Members#############################################
# Requesting to remove-group-member to remove the user
If ($deleteInput -eq "y"){
$requestUrl = "https://api.services.mimecast.com/api/directory/remove-group-member"
#body part
$requestBody = @{
    data = @(
        @{
           id = $id
           emailAddress  =  $results
            
        }
    )
} | ConvertTo-Json

$requestHeaders = @{
    "Authorization" = $token
    "Accept"        = "application/json"
    "Content-Type"  = "application/json"
}

$response = Invoke-RestMethod -Uri $requestUrl -Method POST -Headers $requestHeaders -Body $requestBody
#Converting to Json
$response | ConvertTo-Json -Depth 32 | Write-Host


############################Add group members#############################################
#This calls add-group-member and adds email address
If ($NewEmailAddInput -eq "y"){
$requestUrl = "https://api.services.mimecast.com/api/directory/add-group-member"

$requestBody = @{
    data = @(
        @{
           id = $id
           emailAddress  =  $emailaction
            
        }
    )
} | ConvertTo-Json

$requestHeaders = @{
    "Authorization" = $token
    "Accept"        = "application/json"
    "Content-Type"  = "application/json"
}

$response = Invoke-RestMethod -Uri $requestUrl -Method POST -Headers $requestHeaders -Body $requestBody
#Converst to Json
$response | ConvertTo-Json -Depth 32 | Write-Host
