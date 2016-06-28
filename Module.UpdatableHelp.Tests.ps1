<#	
.SYNOPSIS
Tests updatable help for the commands in a module. 

.DESCRIPTION
This Pester test verifies that the commands in a module have basic help content. 
It works on all command types and both comment-based and XML help.

This test verifies that Get-Help is not autogenerating help because it cannot
find any help for the command. Then, it checks for the following help elements:
	- Synopsis
	- Description
	- Parameter:
		- A description of each parameter.
		- An accurate value for the Mandatory property.
		- An accurate value for the .NET type of the parameter value.
	- No extra parameters:
		- Verifies that there are no parameters in help that are not also in the code.

When testing attributes of parameters that appear in multiple parameter sets,
this test uses the parameter that appears in the default parameter set, if one
is defined.

You can run this Tests file from any location. For a help test that is located in a module 
directory, use https://github.com/juneb/PesterTDD/InModule.Help.Tests.ps1

.PARAMETER ModuleName
Enter the name of the module to test. You can enter only one name at a time. This
parameter is mandatory.

.PARAMETER RequiredVersion
Enter the version of the module to test. This parameter is optional. If you 
omit it, the test runs on the latest version of the module in $env:PSModulePath.

.EXAMPLE
.\Module.Help.Tests.ps1 -ModuleName Pester -RequiredVersion 3.4.0
This command runs the tests on the commands in Pester 3.4.0.

.EXAMPLE
.\Module.Help.Tests.ps1 -ModuleName Pester
This command runs the tests on the commands in latest local version of the
Pester module.


.NOTES
===========================================================================
 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.123
 Created on:   	6/28/2016 9:50 AM
 Created by:   	June Blender
 Organization: 	SAPIEN Technologies, Inc
 Filename:     	Module.UpdatableHelp.Tests.ps1
===========================================================================
#>

Param
(
	[Parameter(Mandatory = $true)]
	[ValidateScript({ Get-Module -ListAvailable -Name $_ })]
	[string]
	$ModuleName,
	
	[Parameter(Mandatory = $false)]
	[System.Version]
	$RequiredVersion
)

#Requires -Module @{ModuleName = 'Pester'; ModuleVersion = '3.4.0'}
#Requires -RunAsAdministrator

if (!$RequiredVersion)
{
	$RequiredVersion = (Get-Module $ModuleName -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1).Version
}

$modSpec = [Microsoft.PowerShell.Commands.ModuleSpecification]@{ ModuleName = $ModuleName; RequiredVersion = $RequiredVersion }

if ((Get-Module -ListAvailable -FullyQualifiedName $modSpec).HelpInfoUri)
{
	Describe "Testing updatable help for $ModuleName ($RequiredVersion)" {
		
		It "Should not fail (no errors of any type)" {
	
			{ Update-Help -FullyQualifiedModule $modSpec -Force -ErrorAction Stop } | Should Not Throw
		}
	}
}
else
{
	Write-Warning "Updatable help is not supported by $ModuleName ($RequiredVersion)"	
}