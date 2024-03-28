# AutomatedBadLab
InfoSec focused Custom Roles for AutomatedLab

## Quick Start
- Enable HyperV
- Upload Windows ISOs to `C:\LabSources\ISOs` (Recommend [Microsoft Evaluation Center](https://www.microsoft.com/en-us/evalcenter/) if MSDN is not available to you)
- Install [AutomatedLab](https://automatedlab.org/en/latest/Wiki/Basic/install/)
    ``` PowerShell
    Install-PackageProvider Nuget -Force
    Install-Module AutomatedLab -SkipPublisherCheck -AllowClobber
    Enable-LabHostRemoting -Force
    New-LabSourcesFolder -DriveLetter C
    ```
- Build a DHCP / Internet Router VM via the [Router Template](./Labs/1.%20Template%20Router.ps1)

## Building Labs
Several templates have been provided in the Labs subdirectory to get started. Additionally, each Custom Role comes with its own README and in some cases a Lab Template to demonstrate its use:
- [AutomatedBadLab Role](./CustomRoles/AutomatedBadLab/README.md)
- [AutomatedBadLab Lab Template](./Labs/1.%20Template%20AutomatedBadLab.ps1)

[RDCMan](https://learn.microsoft.com/en-us/sysinternals/downloads/rdcman) is recommended for managing RDP connection profiles. AutomatedLab updates the local hosts file during the build process, so only NETBIOS names are required to connect to lab machines.

## Further Reading
[TrustedSec Blog Post](https://trustedsec.com/blog/offensive-lab-environments-without-the-suck) provides a great runthrough on how to get set up.

## Acknowledgements
- The [AutomatedLab Team](https://github.com/AutomatedLab/AutomatedLab/graphs/contributors)
- @davidprowe for the inspiration with [BadBlood](https://github.com/davidprowe/BadBlood)
- @TrimarcJake for the ADCS work on [Locksmith](https://github.com/TrimarcJake/Locksmith)

## Disclaimer
THE SCRIPTS PROVIDED IN THIS PACKAGE ARE FOR EDUCATIONAL PURPOSES AND TESTING ONLY. THEY ARE NOT INTENDED TO BE EXECUTED IN A PRODUCTION ENVIRONMENT.

USE OF THESE SCRIPTS IS AT YOUR OWN RISK. THE AUTHOR MAKES NO WARRANTIES AS TO THE FUNCTIONALITY, EFFECTIVENESS, OR SUITABILITY OF THESE SCRIPTS FOR ANY PARTICULAR PURPOSE. THE AUTHOR SHALL NOT BE RESPONSIBLE FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DATA LOSS, SYSTEM DOWNTIME, OR SYSTEM INSTABILITY ARISING FROM YOUR USE OF THESE SCRIPTS.

BY USING THESE SCRIPTS, YOU ACKNOWLEDGE THAT YOU UNDERSTAND AND ACCEPT THESE TERMS.
