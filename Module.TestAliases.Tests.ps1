<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.123
	 Created on:   	6/27/2016 4:49 PM
	 Created by:   	 June Blender
	 Organization: 	SAPIEN Technologies, Inc.
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		ModulesA description of the file.
#>

Param
(
	[Parameter(Mandatory = $true)]
	[ValidateScript({ Get-Module -ListAvailable -Name $_ })]
	[string]$ModuleName = 'BetterCredentials',
	
	[Parameter(Mandatory = $false)]
	[System.Version]$RequiredVersion
)

#Requires -Module @{ModuleName = 'Pester'; ModuleVersion = '3.4.0'}

if (!$RequiredVersion)
{
	$RequiredVersion = (Get-Module $ModuleName -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1).Version
}

if ($ExportedAliases = (Get-Module -ListAvailable -FullyQualifiedName @{ ModuleName = $ModuleName; RequiredVersion = $RequiredVersion }).ExportedAliases.Values.Name)
{
	# Remove all versions of the module from the session. Pester can't handle multiple versions.
	Get-Module $ModuleName | Remove-Module
	
	# Import the required version
	Import-Module $ModuleName -RequiredVersion $RequiredVersion -ErrorAction Stop
	
	foreach ($ExportedAlias in $ExportedAliases)
	{
		Describe "Testing exported aliases" {
			
			$script:AliasInSession = $null
			
			It "Get-Alias should not error out: $ExportedAlias" {
				{ $script:AliasInSession = Get-Alias $ExportedAlias -ErrorAction Stop } | Should Not Throw				
			}
			
			It "Get-Alias should find alias in session: $ExportedAlias" {
				
				$script:AliasInSession.Name | Should Be $ExportedAlias
			}
			
			It "Get-Alias should find value: $ExportedAlias" {
				
				$script:AliasInSession.ResolvedCommandName -or $script:AliasInSession.Definition | Should Be $True
			}
		}
	}
}
else
{
	Write-Host "Module.TestAliases.Tests.ps1:  $ModuleName ($RequiredVersion) does not export any aliases."
}
