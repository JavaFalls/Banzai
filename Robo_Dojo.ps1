# Get the latest version of Robo_Dojo from csmain and run it

Set-Location ($env:USERPROFILE + "\Desktop")

$RoboDojoPath = '\\csmain.studentnet.int\Classes\SE_Project\Software Expo\Final Projects\2019\Robo_Dojo\'
$CD           = (Get-Location).Path
$NewRoboDojo  = [IO.Path]::GetFileNameWithoutExtension((Get-ChildItem $RoboDojoPath | where {$_.Name -like "*Robo_Dojo*" -and $_.Name -like "*.zip" -and $_.Name -notlike "*Scoreboard*" -and $_.Name -notlike "*Debug*"})[0])
$LocalFiles   = (Get-ChildItem $CD | Where {$_.Name -like $NewRoboDojo -and $_.PSIsContainer})
$Artifacts    = (Get-ChildItem $CD | Where {$_.Name -like "*Robo_Dojo*" -and $_.PSIsContainer})

function main {
   if ($NewRoboDojo) {
      Write-Output "Checking Robo Dojo Version"
      if (-Not $LocalFiles) {
         Write-Output "New Version Found, Beginning Update"
         Remove-Artifacts
         Update-RoboDojo
         Extract-Update
      }
      Start-RoboDojo
   }
   else {
      Write-Output "Can`'t find path to server"
      Exit
   }
}

# Remove old files
function Remove-Artifacts {
   if ($Artifacts) {
      Write-Output "Removing All Folders Containing 'Robo_Dojo'"
      Remove-Item $Artifacts -Recurse
   }
   else {
      Write-Output "No Folders Containing 'Robo_Dojo' Found"
   }
}

# Fetch new zip
function Update-RoboDojo {
   Write-Output "Downloading New Version of Robo Dojo"
   Copy-Item -Path ($RoboDojoPath + $NewRoboDojo + ".zip") -Destination $CD
}

# Extract
function Extract-Update {
   Write-Output "Installing Robo Dojo"
   Expand-Archive ($NewRoboDojo + ".zip")
   Remove-Item ($NewRoboDojo + ".zip")
}

# Run
function Start-RoboDojo {
   Write-Output "Starting Robo Dojo"
   Set-Location $NewRoboDojo
   Start-Process Robo_Dojo.bat
}

main