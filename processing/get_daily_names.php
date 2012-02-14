<?php

require_once("ftp_creds.php");

$lastDownload = trim(file_get_contents("last_daily_name_retrieved.txt"));

$nextday = strtotime($lastDownload . " +1 day");

$lastDownloadFormatted = "d" . date("ymd", $nextday) . ".records.xml";
echo $lastDownloadFormatted."\n";

$localfile = LOCALDAYNAMEDIR . $lastDownloadFormatted;
$serverfile = SERVERDAYNAMEDIR . $lastDownloadFormatted;

// set up basic connection
$conn_id = ftp_connect(FTPSERVER);

// login with username and password
$login_result = ftp_login($conn_id, FTPUSER, FTPPASS);

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
