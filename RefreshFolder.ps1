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
    
    #check that $Path is not null
    if(!$Path){ Write-Error "Path is null" ; return }

    # CHeck if that does not exist
    if(!(Test-Path -Path $Path)){ Write-Error "Path does not exist" ; return }

    # check if 

    $file = Get-Item -Path $Path

    # create backup folder if does not exist
    if(!(Test-Path -Path backup)){
        New-Item -Path backup -ItemType Directory
    }

    $id = 0
    do {
        $id++
        $destination = "backup" | Join-Path -ChildPath ("{0}({1}){2}" -f $file.BaseName,$id,$file.Extension)
        Write-Verbose "Destination: $destination"
    } until ( ! ($destination | Test-Path))

    # check if both files are the same
    $previouse = "backup" | Join-Path -ChildPath ("{0}({1}){2}" -f $file.BaseName,($id-1),$file.Extension)

    if(AreEqual -source $file -destination $previouse){
        Write-Verbose "Files are the same"
        return
    }

    # Backup $file
    $file | Copy-Item -Destination $destination
}

function AreEqual($source,$destination){

    # check if both files exist
    if(!(Test-Path -Path $source)){ return $false}
    if(!(Test-Path -Path $destination)){ return $false }

    $sourceHash = Get-FileHash -Path $source
    $destinationHash = Get-FileHash -Path $destination
    return $sourceHash.Hash -eq $destinationHash.Hash
}

$scriptFiles = Get-ChildItem -Path *.scpt

foreach($file in $scriptFiles){
    $codeFile = $file.Directory | Join-Path -ChildPath ($file.BaseName + ".txt")
    backupfile -Path $codeFile
    osadecompile $file.FullName | Out-File -FilePath $codeFile
}


