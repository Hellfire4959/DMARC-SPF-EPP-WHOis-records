# DNS and WhoisXML API enrichment for a workbook with a Domain column.
[CmdletBinding()]
param (
    [Parameter(Mandatory)][string]$InputPath,
    [Parameter(Mandatory)][string]$OutputPath,
    [string]$ApiKey = $env:WHOISXML_API_KEY
)

$inputFilePath = $InputPath
$outputFilePath = $OutputPath

if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    throw 'ImportExcel is required. Run: Install-Module ImportExcel -Scope CurrentUser'
}
Import-Module ImportExcel -ErrorAction Stop
$null = Get-Command Resolve-DnsName -ErrorAction Stop
if (-not (Test-Path -LiteralPath $InputPath -PathType Leaf)) {
    throw "Input workbook not found: $InputPath"
}
if ([IO.Path]::GetFullPath($InputPath) -eq [IO.Path]::GetFullPath($OutputPath)) {
    throw 'Input and output paths must be different.'
}

if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    throw 'Set WHOISXML_API_KEY or supply -ApiKey before using the WHOIS mode.'
}
$inputData = @(Import-Excel -Path $inputFilePath)
if ($inputData.Count -eq 0 -or -not ($inputData[0].PSObject.Properties.Name -contains 'Domain')) {
    throw 'The first worksheet must contain data and a Domain column.'
}

# Create an empty array to store the results
$outputData = @()

# Process each domain in the input file
foreach ($row in $inputData) {
# Retrieve the domain from the input data
$domain = [string]$row.Domain
if ([string]::IsNullOrWhiteSpace($domain)) { continue }
$domain = $domain.Trim()
$encodedDomain = [Uri]::EscapeDataString($domain)
$encodedKey = [Uri]::EscapeDataString($ApiKey)

# Construct the WhoisXML API URL for Whois record
$url = "https://www.whoisxmlapi.com/whoisserver/WhoisService?apiKey=$encodedKey&domainName=$encodedDomain&outputFormat=JSON"

# Invoke the API and retrieve the Whois record response
try {
    $whoisResponse = Invoke-RestMethod -Uri $url -ErrorAction Stop
}
catch {
    throw "WHOIS request failed for $domain. Check the API credentials, quota and network connection."
}
if ($whoisResponse.ErrorMessage -or -not $whoisResponse.WhoisRecord) {
    throw "WHOIS returned no usable record for $domain. Check the provider response and account quota."
}

# Extract the EPP status (Domain Status)
$domainStatus = $whoisResponse.WhoisRecord.registryData.status -join ", "

# Retrieve SPF records
$spfRecords = Resolve-DnsName -Type TXT -Name $domain -ErrorAction SilentlyContinue | Where-Object {$_.Strings -like "v=spf1*"}
$spfRecords = if ($spfRecords) { $spfRecords.Strings } else { "No SPF records found." }

# Retrieve DMARC records
$dmarcRecords = Resolve-DnsName -Type TXT -Name "_dmarc.$domain" -ErrorAction SilentlyContinue | Where-Object {$_.Strings -like "v=DMARC1*"}
$dmarcRecords = if ($dmarcRecords) { $dmarcRecords.Strings } else { "No DMARC records found." }

# Extract the registrant information
$registrantInfo = $whoisResponse.WhoisRecord.registrant
$registrantOrganization = $registrantInfo.organization
$registrantName = $registrantInfo.name
$registrantEmail = $registrantInfo.email
$registrantPhone = $registrantInfo.telephone
$registrantFax = $registrantInfo.fax
$registrantAddress = "$($registrantInfo.street), $($registrantInfo.city), $($registrantInfo.state), $($registrantInfo.postalCode), $($registrantInfo.country)"

# Extract the nameserver information
$nameservers = $whoisResponse.WhoisRecord.nameServers.hostNames -join ", "

# Extract the abuse contact information
$abuseContact = $whoisResponse.WhoisRecord.abuseEmail

# Create a new object with the extracted data
$outputRow = [PSCustomObject]@{
Domain = $domain
"EPP Status (Domain Status)" = $domainStatus
SPF = $spfRecords
DMARC = $dmarcRecords
"Registrant Organization" = $registrantOrganization
"Registrant Name" = $registrantName
"Registrant Email" = $registrantEmail
"Registrant Phone" = $registrantPhone
"Registrant Fax" = $registrantFax
"Registrant Address" = $registrantAddress
"Nameservers" = $nameservers
"Abuse Contact" = $abuseContact
}

# Add the row to the output array
$outputData += $outputRow
}

# Export the output data to Excel
$outputData | Export-Excel -Path $outputFilePath -AutoSize -AutoFilter

# Output the completion message
Write-Host "Output file generated successfully at: $outputFilePath"
