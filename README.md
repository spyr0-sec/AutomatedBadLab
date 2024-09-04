# AutomatedBadLab
InfoSec focused Custom Roles for AutomatedLab

## Quick Start
Run `Functions\Install-AutomatedLab.ps1`

## Building Labs
The easiest way to get a machine is to start with is to run [Standalone Template](./Labs/1.%20Template%20Internet%20Connected%20Standalone.ps1)
1. (First time only) Create a Windows 11 Base image to make subsequent builds much quicker
2. Create a Windows 11 Machine
3. Run a Windows Update Scheduled task to install all available updates

To build a vulnerable Active Directory, run the [AutomatedBadLab Template](./Labs/1.%20Template%20AutomatedBadLab.ps1). 

Each [Custom Role](./CustomRoles/AutomatedBadLab/README.md) comes with its own README and in some cases a Lab Template to demonstrate its use.

## Notes
If you are running AutomatedBadLab on a Virtual Machine, the recomendation is to build a DHCP / Internet Router VM via the [Router Template](./Labs/1.%20Template%20Router.ps1).

Example [Active Directory Template](./Labs/1.%20Template%20Active%20Directory.ps1) which uses the dual-NIC configuration.

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
