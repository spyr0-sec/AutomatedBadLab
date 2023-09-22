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
- OPTIONAL BUT RECOMMENDED
    - Take a copy / modify the Router template file within Labs
    - Update all parameters within the first comment block
    - Execute the script to create a DHCP / Internet router 

## CustomRoles / PostInstallationActivities
There are also several other scripts provided that may be useful when setting up other types of environments.

## Acknowledgements
- The [AutomatedLab Team](https://github.com/AutomatedLab/AutomatedLab/graphs/contributors)
- @davidprowe for the inspiration with [BadBlood](https://github.com/davidprowe/BadBlood)
- @TrimarcJake for the ADCS work on [Locksmith](https://github.com/TrimarcJake/Locksmith)

## Disclaimer
THE SCRIPTS PROVIDED IN THIS PACKAGE ARE FOR EDUCATIONAL PURPOSES AND TESTING ONLY. THEY ARE NOT INTENDED TO BE EXECUTED IN A PRODUCTION ENVIRONMENT.

USE OF THESE SCRIPTS IS AT YOUR OWN RISK. THE AUTHOR MAKES NO WARRANTIES AS TO THE FUNCTIONALITY, EFFECTIVENESS, OR SUITABILITY OF THESE SCRIPTS FOR ANY PARTICULAR PURPOSE. THE AUTHOR SHALL NOT BE RESPONSIBLE FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DATA LOSS, SYSTEM DOWNTIME, OR SYSTEM INSTABILITY ARISING FROM YOUR USE OF THESE SCRIPTS.

BY USING THESE SCRIPTS, YOU ACKNOWLEDGE THAT YOU UNDERSTAND AND ACCEPT THESE TERMS.
