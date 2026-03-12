# AutomatedBadLab
PowerShell scripts to create sandboxed or vulnerable environments using HyperV and AutomatedLab

## Quick Start
[Run the install script](./Functions/Install-AutomatedBadLab.ps1)

## Building Labs
To build a vulnerable Active Directory, run the [AutomatedBadLab Template](./Labs/1.%20Template%20AutomatedBadLab.ps1). 

Each [Custom Role](./CustomRoles/AutomatedBadLab/README.md) comes with its own README and in some cases a Lab Template to demonstrate its use.

## Notes
AutomatedLab > v5.60.0 is required due to the use of NAT enabled vSwitches

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
