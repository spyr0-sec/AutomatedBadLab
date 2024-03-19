# AutomatedBadLab
Scripts to create vulnerable and testing environments using AutomatedLab

## Quick Start
- Windows machine with HyperV Enabled
- Windows ISOs (Recommend [Microsoft Evaluation Center](https://www.microsoft.com/en-us/evalcenter/) if MSDN is not available to you)
- Install [AutomatedLab](https://automatedlab.org/en/latest/Wiki/Basic/install/)
    ```powershell
    Install-PackageProvider Nuget -Force
    Install-Module AutomatedLab -SkipPublisherCheck -AllowClobber
    Enable-LabHostRemoting -Force
    New-LabSourcesFolder -DriveLetter C
    ```
- Change parameters at the top of the [Standalone Template](Labs/1.%20Template%20Standalone.ps1) and run
- OPTIONAL BUT RECOMMENDED
    - Modify the Router template file
    - Update all parameters within the first comment block
    - Execute the script to create a DHCP router to provide routing between lab networks

## Advanced Labs
There are also several other scripts provided to provision more complex labs:
- [Lab Templates](./Labs/README.md)
- [AutomatedBadLab Provisioning](./PostInstallationActivities/AutomatedBadLab/README.md)

## Acknowledgements
- The [AutomatedLab Team](https://github.com/AutomatedLab/AutomatedLab/graphs/contributors)
- @davidprowe for the inspiration with [BadBlood](https://github.com/davidprowe/BadBlood)
- @TrimarcJake for the ADCS work on [Locksmith](https://github.com/TrimarcJake/Locksmith)

## Disclaimer
THE SCRIPTS PROVIDED IN THIS PACKAGE ARE FOR EDUCATIONAL PURPOSES AND TESTING ONLY. THEY ARE NOT INTENDED TO BE EXECUTED IN A PRODUCTION ENVIRONMENT.

USE OF THESE SCRIPTS IS AT YOUR OWN RISK. THE AUTHOR MAKES NO WARRANTIES AS TO THE FUNCTIONALITY, EFFECTIVENESS, OR SUITABILITY OF THESE SCRIPTS FOR ANY PARTICULAR PURPOSE. THE AUTHOR SHALL NOT BE RESPONSIBLE FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DATA LOSS, SYSTEM DOWNTIME, OR SYSTEM INSTABILITY ARISING FROM YOUR USE OF THESE SCRIPTS.

BY USING THESE SCRIPTS, YOU ACKNOWLEDGE THAT YOU UNDERSTAND AND ACCEPT THESE TERMS.
