<#
.SYNOPSIS
    Refreshes the folder by decompiling all the scripts and moving them to a backup folder
.DESCRIPTION
    Refreshes the folder by decompiling all the scripts and moving them to a backup folder
.EXAMPLE
    RefreshFolder.ps1
#>
[CmdletBinding(SupportsShouldProcess)]
param(
)

function backupfile($Path){
    # create backup folder if does not exist
    if(!(Test-Path -Path backup)){
        New-Item -Path backup -ItemType Directory
    }

    #check that $Path is not null
    if(!$Path){
        Write-Error "Path is null"
        return
    }

    $id = 0
    do {
        $destination = "backup" | Join-Path -ChildPath ("{0}({1}).txt" -f $path.basename,$id++)
        Write-Verbose "Destination: $destination"
    } until ( ! ($destination | Test-Path))

    Move-Item -Path $path -Destination $destination
}

$scriptFiles = Get-ChildItem -Path *.scpt

foreach($file in $scriptFiles){
    backupfile -Path $file
    osadecompile $file.FullName | Out-File -FilePath $file.FullName
}


