<#	
	.NOTES
		===========================================================================
		Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.119
		Created on:   	4/12/2016 1:11 PM
		Created by:   	June Blender
		Organization: 	SAPIEN Technologies, Inc
		Filename:		*.Help.Tests.ps1
		===========================================================================
	.DESCRIPTION
	To test help for the commands in a module, place this file in the module folder.
	To test any module from any path, use https://github.com/juneb/PesterTDD/Module.Help.Tests.ps1
#>

$moduleBase = Split-Path -Parent $MyInvocation.MyCommand.Path

# Handles modules in version directories
$leaf = Split-Path $ModuleBase -Leaf
$parent = Split-Path $ModuleBase -Parent
$parsedVersion = $null
if ([System.Version]::TryParse($leaf, [ref]$parsedVersion))
{
	$moduleName = Split-Path $parent -Leaf
}
else
{
	$moduleName = $leaf
}

# Removes all versions of the module from the session before importing
Get-Module $moduleName | Remove-Module

# Because ModuleBase includes version number, this imports the required version
# of the module
$module = Import-Module $ModuleBase\$ModuleName.psd1 -PassThru -ErrorAction Stop
$commands = Get-Command -Module $module

# List of the common parameters to exclude later
$commonParameters = @(
	'Debug', 
	'ErrorAction', 
	'ErrorVariable', 
	'InformationAction', 
	'InformationVariable', 
	'OutBuffer', 
	'OutVariable',
	'PipelineVariable', 
	'Verbose', 
	'WarningAction', 
	'WarningVariable'
)

## When testing help, remember that help is cached at the beginning of each session.
## To test, restart session.

foreach ($command in $commands)
{
	$commandName = $command.Name
	$commandHelp = Get-Help $command -ErrorAction SilentlyContinue
	
	Describe "Test help for $commandName" {
		
		# If help is not found, synopsis in auto-generated help is the syntax diagram
		It "should not be auto-generated" {
			
			$commandHelp.Synopsis | Should Not BeLike '*`[`<CommonParameters`>`]*'
		}
		
		# Should be a description for every function
		It "gets description for $commandName" {
			
			$commandHelp.Description | Should Not BeNullOrEmpty
		}
		
		# Should be at least one example
		It "gets example code from $commandName" {
			
			$example = $commandHelp.Examples.Example | Select-Object -First 1
			$example | Should Not BeNullOrEmpty
			$example.Code | Should Not BeNullOrEmpty
		}
		
		# Should be at least one example description
		It "gets example help from $commandName" {
			
			$remarks = $commandHelp.Examples.Example.Remarks | Select-Object -First 1
			$remarks | Should Not BeNullOrEmpty
			$remarks.Text | Should Not BeNullOrEmpty
		}
		
		Context "Test parameter help for $commandName" {
			
			$parameterNames = (Get-Command $command).ParameterSets.Parameters.Name | Sort-Object -Unique
			$filteredNames = $parameterNames  | Where-Object { $_ -notin $commonParameters }
			
			foreach ($parameterName in $filteredNames)
			{
				# Should be a description for every parameter
				It "gets help for parameter: $parameterName" {
					
					$parameterHelp = Get-Help $command -Parameter $parameterName -ErrorAction SilentlyContinue
					
					$parameterHelp | Should Not BeNullOrEmpty
					$parameterHelp.Description | Should Not BeNullOrEmpty
					$parameterHelp.Description.Text | Should Not BeNullOrEmpty
				}
			}
		}
	}
}
