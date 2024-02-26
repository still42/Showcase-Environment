Configuration CreateADDS
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Domainname,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential] $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential] $SafeModePassword
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc
    Import-DscResource -ModuleName ComputerManagementDsc

    Node 'localhost'
    {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        WindowsFeature 'DNS' {
            Name    = "DNS"
            Ensure  = "Present"
        }

        Script GuestAgent {
            SetScript = {
                Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\WindowsAzureGuestAgent' -Name DependOnService -Type MultiString -Value DNS
                Write-Verbose -Verbose "GuestAgent depends on DNS"
            }
            GetScript = { @{} }
            TestScript = { $false }
            DependsOn = "[WindowsFeature]DNS"
        }
        
        WindowsFeature 'RSAT-DNS-Server' {
            Ensure    = "Present"
            Name      = "RSAT-DNS-Server"
            DependsOn = "[WindowsFeature]DNS"
        }

        WindowsFeature 'ADDS' {
            Name    = 'AD-Domain-Services'
            Ensure  = 'Present'
        }

        WindowsFeature 'RSAT-ADDS'
        {
            Name        = 'RSAT-ADDS'
            Ensure      = 'Present'
            DependsOn   = "[WindowsFeature]ADDS"
        }

        WindowsFeature 'RSAT-AD-Powershell'
        {
            Name        = 'RSAT-AD-PowerShell'
            Ensure      = 'Present'
            DependsOn   = "[WindowsFeature]ADDS"
        }

        ADDomain 'ntwrk.com'
        {
            DomainName                    = $Domainname
            Credential                    = $Credential
            SafemodeAdministratorPassword = $SafeModePassword
            ForestMode                    = 'WinThreshold'
            DependsOn                     = "[WindowsFeature]ADDS"
        }

    }
}
