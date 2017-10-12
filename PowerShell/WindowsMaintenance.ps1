<#
Change the values of these variables to "yes"
to include that particular part of the script in the runtime.
$updates = "yes"  : check for windows updates.
$defrag = "yes"   : defragment system volume
$chkdsk = "yes"   : schedule a disk check on the next restart for the system volume
$ccleaner = "yes" : install, run, and uninstall CCleaner
$java = "yes"     : download and install Java
$adobe = "yes"    : download and install Adobe Flash Player and Reader
$clrtemp = "yes"  : manually delete contents of %tmp% folder
#>

$updates = "no"
$chkdsk = "no"
$ccleaner = "no"
$java = "no"
$adobe = "yes"
$clrtemp = "no"
$defrag = "no"

<#
If the links for the latest versions of the software get old,
you can change them here.
$CCLink : CCleaner
$javaLink : Java
$FPNPAPILink : Flash Player for NPAPI (Firefox)
$FPAXLink : Flash Player for ActiveX (Internet Explorer)
$ReaderLink : Adobe Reader
#>

$CCLink = "http://download.piriform.com/ccsetup535.exe"
$javaLink = "http://javadl.oracle.com/webapps/download/AutoDL?BundleId=225355_090f390dda5b47b9b721c7dfaa008135"
$FPNPAPILink = "https://fpdownload.macromedia.com/pub/flashplayer/latest/help/install_flash_player.exe"
$FPAXLink = "https://fpdownload.macromedia.com/pub/flashplayer/latest/help/install_flash_player_ax.exe"
$ReaderLink = "http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1701220093/AcroRdrDC1701220093_en_US.exe"

$wc = New-Object System.Net.WebClient

#determine windows version
if(([System.Environment]::OSVersion.Version).major -eq "10") {
  $version = "10"
} elseif (([System.Environment]::OSVersion.Version).major -ge "6.1") {
  $version = "78"
} else {
  echo "Can't support this version of windows."
  return
}

#Start checking for updates
if($updates -eq "yes") {
  echo "Checking for Windows Updates..."
  if($version -eq "10") {
    (New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()
  }
  else {
    cmd.exe /c "wuauclt /ShowWUAutoScan"
  }
}

#defragment main disk
if($defrag -eq "yes") {
  echo "Defragmenting main volume"
  cmd.exe /c "defrag %systemdrive%"
}

#install and run CCleaner
if($ccleaner -eq "yes") {
  echo "Downloading CCleaner..."
  $wc.DownloadFile($CCLink, "$ENV:TEMP\ccsetup.exe");
  cd $ENV:TEMP
  echo "Running CCleaner..."
  cmd.exe /c "ccsetup.exe /S"
  cd $ENV:PROGRAMW6432\CCleaner
  cmd.exe /c "CCleaner64 /Auto"
}

#install java
if($java -eq "yes") {
  echo "Downloading Java..."
  $wc.DownloadFile($javaLink, "$ENV:TEMP\java.exe");
  cd $ENV:TEMP
  echo "Installing Java..."
  cmd.exe /c "java.exe INSTALL_SILENT=Enable REMOVEOUTOFDATEJRES=1"
}

#install latest versions of flash and reader
if($adobe -eq "yes") {
echo "Downloading Flash Player NPAPI..."
$wc.DownloadFile($FPNPAPILink, "$ENV:TEMP\install_flash_player.exe");
echo "Downloading Flash Player ActiveX..."
$wc.DownloadFile($FPAXLink, "$ENV:TEMP\install_flash_player_ax.exe");
echo "Downloading Adobe Reader..."
$wc.DownloadFile($ReaderLink, "$ENV:TEMP\AcroRdrDC1701220093_en_US.exe");

cd $ENV:TEMP
echo "Installing Flash Player NPAPI..."
cmd.exe /c "install_flash_player.exe -install"
echo "Installing Flash Player ActiveX..."
cmd.exe /c "install_flash_player_ax.exe -install"
echo "Installing Adobe Reader DC..."
cmd.exe /c "AcroRdrDC1701220093_en_US.exe /sAll /rs"
}

#cleanup
if($ccleaner -eq "yes") {
echo "Uninstalling CCleaner..."
cd $ENV:PROGRAMW6432\CCleaner
cmd.exe /c "uninst /S"
}

if($clrtemp -eq "yes") {
echo "Clearing the temp folder..."
cd $ENV:TEMP
cmd.exe /c "del * /S /Q"
}

#chkdsk main disk on restart
if($chkdsk -eq "yes") {
  echo "Will perform a checkdisk on next restart"
  cmd.exe /c "echo y | chkdsk %systemdrive% /f /r"
}

echo "Done with script."
