$funcURI = "" # your function URL

$user = "" # your test user UPN
$fp = Split-Path $PSScriptRoot -Parent

Describe "Function App Call" {
    $iwr = Invoke-WebRequest -Method Get -Uri "$funcUri&user=$user"
    $toMap = $iwr.Content | ConvertFrom-Json
    Context "Checking result of REST call" {
        it 'Function call should return 200' { $iwr.StatusCode | Should be 200 }
        it 'Function content should be well formed JSON' { $toMap | should not be $null }
    }
    Context "Checking drive map object returned from REST call" {
        $hash = (Get-FileHash "$fp\function-app\aad-sec-grp-qry\drivemaps.json").Hash
        $hashCheck = $hash.Substring($hash.Length -6, 6)
        it 'The configuration JSON should match' { $toMap.hash | should be $hashCheck }
        it 'We should have some base drives' { $toMap.drives.count | Should not be $null }
        it 'We should have some printers' { $toMap.printers | Should not be $null }
    }
}