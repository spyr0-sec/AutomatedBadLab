# AD Object Creation
$ADCreateFunctions = Get-ChildItem "$PSScriptRoot/AD_Create_*" -Recurse -Include "*.ps1" 

foreach ($ADCreateFunction in $ADCreateFunctions) {
    . $ADCreateFunction
}

# ATTACK
$ADAttackFunctions = Get-ChildItem "$PSScriptRoot/AD_Attack_Vectors" -Recurse -Include "*.ps1" 

foreach ($ADAttackFunction in $ADAttackFunctions) {
    . $ADAttackFunction
}
