# Labs
These scripts are provided to assist getting labs up and running as easily as possible

## Templates
All templates are headered with a section of common parameters to change. The only other considerations are if a external network has been configured and the names of your VMs.

- Active Directory (<1hr build time)
    - Domain Controller + Workstation
    - Explains several AutomatedLab features
        - Roles / PostInstallationActivities / Running remote commands etc.
- AutomatedBadLab (~3hr build time - much less if OS updates are not required)
    - Domain Controller + Certificate Authority + Workstation
    - Updates operating systems (Useful if using evaluation ISOs)
    - Provisions AutomatedBadLab with several AD & ADCS vulnerabilities (See PostInstallationActivities\AutomatedBadLab\README.md for full details)
    - Removes Windows Defender from the Workstation
    - Includes AutomatedBadLab revert script - useful for debugging
- Router (~20 minutes build time)
    - Windows Server with DHCP Role
    - Configures NAT on your local machine to provide external routing to other Lab machines 
- Standalone (~10 minutes build time)
    - Creates a single internet-connected box
- WDAC (~10 minutes build time)
    - Example of Custom Roles which install a user defined WDAC policy
- DevBox (~30 minutes build time)
    - Machine pre-installed with Visual Studio + VS Code for development

As this is pure Powershell, this should (hopefully) provide consistent and repeatable environments. However AutomatedLab does come with [checkpoint](https://automatedlab.org/en/latest/AutomatedLab/en-us/Checkpoint-LabVM/) functionality that is useful rather than recreating the whole environment. 