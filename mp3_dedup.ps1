$ErrorActionPreference = "SilentlyContinue"
# Assert USB drive is used for storing music collection, make sure only one is attached
$Disk = Get-Disk | Where-Object -FilterScript { $_.Bustype -Eq "USB" }
# Get drive letter
$USBDrive = $Disk | Get-Partition | select DriveLetter -ExpandProperty DriveLetter
$Path = ${USBDrive} + ":\"
# Get all mp3 files recursively, adjust depth parameter accordingly
$files = Get-ChildItem -Recurse -Filter *.mp3 $Path -Depth 5
# count number of mp3 files 
$total = $files.Count
# Check duplicate files including from different directories
$duplicates = $files | select name, directoryName, LastWriteTime | group name | where count -gt 1
$duplicates = $duplicates.group
$total_dupes = $duplicates.count
Write-Host "Total number of mp3 files:" $total -ForegroundColor Yellow
Write-Host "Total duplicate mp3 files:" $total_dupes -ForegroundColor Yellow
# Create unique duplicate list 
$unique = $duplicates | Sort-Object -Property name -Unique 

if ($unique -ne $null) {

    foreach ($track in $unique) {
        $move_duplicates += $track.DirectoryName + "\" + $track.name + "`n"
    }
    $move_duplicates | Out-File -FilePath ($Path + "backup\" + "export.txt")


    $file_list = Get-Content ($Path + "backup\" + "export.txt")
    $count = 0
# Move files to backup folder in root of usb drive, make sure backup folder exists
    foreach ($item in $file_list) {
        Move-Item $item -Destination ($Path + "backup") 
        Write-Host "MP3 file $item succesfully moved"
        $count++
    }
    
    Write-Host "Total mp3 files moved: $count" -ForegroundColor Green
}
else {
    Write-Host "No duplicate files found." -ForegroundColor Green
}
