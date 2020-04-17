$modules = Get-Module -ListAvailable

$fp = Split-Path $PSScriptRoot -Parent
if ($modules -notcontains 'pester') {
    Install-Module Pester -Scope CurrentUser -SkipPublisherCheck -ErrorAction SilentlyContinue -Force
}
if ($modules -notcontains 'TestJsonSchema') {
    Install-Module TestJsonSchema -Scope CurrentUser -SkipPublisherCheck -ErrorAction SilentlyContinue -Force
}

if (!(Test-Path $fp\.tests\)) {
    new-item $fp\.tests -ItemType Directory -Force
}

Invoke-Pester -Script "$PSScriptRoot\uat.publish.test.ps1" -OutputFile "$fp\.tests\pester.uat.test.xml" -OutputFormat 'NUnitXml'