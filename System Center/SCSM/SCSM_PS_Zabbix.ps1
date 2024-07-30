#Copy this script into Scripts folder in your zabbix agent 2 folder

[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet("SCSMDWJobs","SCSMWorkflow")]
    [System.String]$Operation
)

$SCSMDWHCMDLETS = "C:\Program Files\Microsoft System Center 2012 R2\Service Manager\Microsoft.EnterpriseManagement.Warehouse.Cmdlets.psd1"
$SCSMDWHCMDLETSAlternative = "C:\Program Files\Microsoft System Center\Service Manager\Microsoft.EnterpriseManagement.Warehouse.Cmdlets.psd1"
$SCSMCMDLETS = "C:\Program Files\Microsoft System Center 2012 R2\Service Manager\PowerShell\System.Center.Service.Manager.psd1"
$SCSMCMDLETSAlternative = "C:\Program Files\Microsoft System Center\Service Manager\PowerShell\System.Center.Service.Manager.psd1"

IF (Test-Path $SCSMDWHCMDLETS)
        {
            Import-Module -force $SCSMDWHCMDLETS
        }
        else
        {
            Import-Module -force $SCSMDWHCMDLETSAlternative
        }
IF (Test-Path $SCSMCMDLETS)
        {
            Import-Module -force $SCSMCMDLETS
        }
        else
        {
            Import-Module -force $SCSMCMDLETSAlternative
        }



#Import-Module -force "C:\Program Files\Microsoft System Center 2012 R2\Service Manager\Microsoft.EnterpriseManagement.Warehouse.Cmdlets.psd1"
#import-module -force "C:\Program Files\Microsoft System Center 2012 R2\Service Manager\PowerShell\System.Center.Service.Manager.psd1"

function Get-SCSMDWJobs{
$command = Get-Command -Name Get-SCDWJob -ErrorAction SilentlyContinue
IF ($command)
        {
            try{
            $SCJobs = Get-SCDWJob | Select NAME,STATUS,CATEGORYNAME -ErrorAction Stop
            $SCJobs = ConvertTo-Json -Compress -InputObject @($SCJobs)
            Write-Output $SCJobs
            }
            catch
            {
            $ErrorMessage = $_.Exception.Message
            Write-output "[{"Name":"Error","Status":"Error","CategoryName":"$($ErrorMessage)"}]"
            }
        }
           #else 
            #{Write-Output "[]"}
}

function Get-SCSMWorkflow{

 #-ErrorAction Stop
$command = Get-Command -Name Get-SCSMWorkflowStatus -ErrorAction SilentlyContinue
IF ($command)
        {
            $workflow = Get-SCSMWorkflowStatus |Where-Object {$_.Enabled -eq "true"} |Sort-Object Name|Select-Object NAME,MANAGEMENTPACKNAME,STATUS,DISPLAYNAME
            $workflow  = ConvertTo-Json -Compress -InputObject @($workflow)
            Write-Output $workflow
        }
#else
    #{Write-Output "[]"}

}



switch ($Operation) {
    "SCSMDWJobs" {
        Get-SCSMDWJobs
    }
    "SCSMWorkflow" {
        Get-SCSMWorkflow
    }
    default {
        Write-Output "-- ERROR -- : Need an option  !"
        Write-Output "This script is not intended to be run directly but called by Zabbix."
    }
}