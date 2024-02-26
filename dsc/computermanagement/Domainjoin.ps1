Configuration Domainjoin
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Computername,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Domainname,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential] $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc

    Node 'localhost'
    {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        Computer 'JoinDomain' {
            Name = $Computername
            DomainName = $Domainname
            Credential = $Credential
        }

    }
}
