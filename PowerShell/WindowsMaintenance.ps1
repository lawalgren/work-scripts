$CCLink = "http://download.piriform.com/ccsetup535.exe"

$javaLink = "http://javadl.oracle.com/webapps/download/AutoDL?BundleId=225355_090f390dda5b47b9b721c7dfaa008135"

$FPNPAPILink = "https://fpdownload.macromedia.com/pub/flashplayer/latest/help/install_flash_player.exe"

$FPAXLink = "https://fpdownload.macromedia.com/pub/flashplayer/latest/help/install_flash_player_ax.exe"

$ReaderLink = "https://admdownload.adobe.com/bin/live/readerdc_en_xa_cra_install.exe"

$wc = New-Object System.Net.WebClient

if(([System.Environment]::OSVersion.Version).major -eq "10") {
  $version = "10"
} elseif (([System.Environment]::OSVersion.Version).major -ge "6.1") {
  $version = "78"
} else {
  echo "Can't support this version of windows."
  return
}

$updates = "no"
$defrag = "no"
$chkdsk = "no"
$ccleaner = "no"
$java = "no"
$adobe = "no"
$clrtemp = "no"

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

#chkdsk main disk on restart
if($chkdsk -eq "yes") {
  echo "Will perform a checkdisk on next restart"
  cmd.exe /c "echo y | chkdsk %systemdrive% /f /r"
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

if($java -eq "yes") {
  echo "Downloading Java..."
  $wc.DownloadFile($javaLink, "$ENV:TEMP\java.exe");
  cd $ENV:TEMP
  echo "Installing Java..."
  cmd.exe /c "java.exe INSTALL_SILENT=Enable REMOVEOUTOFDATEJRES=1"
}

if($adobe -eq "yes") {
echo "Downloading Flash Player NPAPI..."
$wc.DownloadFile($FPNPAPILink, "$ENV:TEMP\install_flash_player.exe");
echo "Downloading Flash Player ActiveX..."
$wc.DownloadFile($FPAXLink, "$ENV:TEMP\install_flash_player_ax.exe");
echo "Downloading Adobe Reader..."
$wc.DownloadFile($ReaderLink, "$ENV:TEMP\readerdc_en_xa_cra_install.exe");

echo "Installing Flash Player and Reader..."
cmd.exe /c "install_flash_player.exe -install"
cmd.exe /c "install_flash_player_ax.exe -install"
cmd.exe /c "readerdc_en_xa_cra_install.exe /sALL /rs"
}

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

echo "Done with script."
