<?php

date_default_timezone_set('America/New_York');

require_once("ftp_creds.php");

$lastDownload = trim(file_get_contents("last_daily_name_retrieved.txt"));

$nextday = strtotime($lastDownload . " +1 day");

$lastDownloadFormatted = "d" . date("ymd", $nextday) . ".records.xml";

$localfile = LOCALDAYNAMEDIR . $lastDownloadFormatted;
$serverfile = SERVERDAYNAMEDIR . $lastDownloadFormatted;

// set up basic connection
$conn_id = ftp_connect(FTPSERVER) or die("Failed to connect to " . FTPSERVER);

// login with username and password
$login_result = ftp_login($conn_id, FTPUSER, FTPPASS) or die("Failed to login to " . FTPSERVER . " as " . FTPUSER);

// turn passive mode on
ftp_pasv($conn_id, true);

echo "Retrieving $lastDownloadFormatted \n";

// try to download $server_file and save to $local_file
if (ftp_get($conn_id, $localfile, $serverfile, FTP_BINARY)) {
    echo "Daily CDS name file successfully written to $localfile\n";
    file_put_contents("last_daily_name_retrieved.txt" , date("Y-m-d" , $nextday));
} else {
    echo "There was a problem retrieving the CDS daily name file.\n";
}
// close the connection
ftp_close($conn_id);



?>
