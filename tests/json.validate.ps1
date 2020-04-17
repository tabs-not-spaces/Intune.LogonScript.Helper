param (
    [Parameter(mandatory = $true)]
    $json,

    [Parameter(mandatory = $true)]
    $schema
)

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
Test-JsonSchema -JsonPath $json -SchemaPath $schema -OutputFile "$fp\.tests\pester.json.test.xml" -OutputFormat 'NUnitXml'