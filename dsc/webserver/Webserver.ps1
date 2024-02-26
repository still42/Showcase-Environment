Configuration Webserver
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

        WindowsFeature 'Web-Server' {
            Name = "Web-Server"
            Ensure = "Present"
            DependsOn = "[Computer]JoinDomain"
        }

        WindowsFeature 'WebManagementService' {
            Name   = "Web-Mgmt-Service"
            Ensure = "Present"
            DependsOn = "[Computer]JoinDomain"
        }

        WindowsFeature 'ASPNet45' {
            Name   = "Web-Asp-Net45"
            Ensure = "Present"
            DependsOn = "[Computer]JoinDomain"
        }

        WindowsFeature 'HTTPRedirection' {
            Name   = "Web-Http-Redirect"
            Ensure = "Present"
            DependsOn = "[Computer]JoinDomain"
        }

        WindowsFeature 'BasicAuthentication' {
            Name   = "Web-Basic-Auth"
            Ensure = "Present"
            DependsOn = "[Computer]JoinDomain"
        }

        WindowsFeature 'WindowsAuthentication' {
            Name   = "Web-Windows-Auth"
            Ensure = "Present"
            DependsOn = "[Computer]JoinDomain"
        }

    }
}
