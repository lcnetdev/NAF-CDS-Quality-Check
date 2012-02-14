xquery version "1.0-ml";

(:
:   Module Name: Main Page for MARC Authorities Report
:
:   Module Version: 1.0
:
:   Date: 2012 Feb 10
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: xdmp (MarkLogic)
:
:   Xquery Specification: January 2007
:
:   Module Overview:     Creates a custom HTTP error page for 
:       the application.  It should be pretty and glorious!
:)

(:~
:   Creates a custom HTTP error page for 
:   the application.  It should be pretty and glorious!
:
:   @author Kevin Ford (kefo@loc.gov)
:   @since May 31, 2011
:   @version 1.0
:)

(: MODULES :)
import module namespace constants      = "info:lc/auth-report/constants#" at "constants.xqy";
import module namespace transmit       = "info:lc/id-modules/transmit#" at "modules/module.Transmit.xqy";


(: NAMESPACES :)
declare namespace xhtml="http://www.w3.org/1999/xhtml";  
declare namespace xdmp = "http://marklogic.com/xdmp";
declare namespace dir = "http://marklogic.com/xdmp/directory";
declare namespace activity = "http://local/activity#";

let $activity-log-file := xdmp:unquote(xdmp:filesystem-file($constants:ACTIVITY_LOG))
let $processed-files := 
    <activity:pfs>
    {
        for $a in $activity-log-file/activity:activity/activity:processed
        order by $a/@datetime ascending
        return $a
    }
    </activity:pfs>

let $files := xdmp:filesystem-directory($constants:DAYNAME_DIR)

let $filestable :=
    <xhtml:table style="width: 100%;border-spacing: 3px;">
        <xhtml:tr style="font-weight: bold;">
            <xhtml:td style="width: 40%;">File</xhtml:td>
            <xhtml:td style="width: 10%;">Processed</xhtml:td>
            <xhtml:td style="width: 30%;">Processed Date</xhtml:td>
            <xhtml:td style="width: 20%;">Action</xhtml:td>
        </xhtml:tr>
        {
            for $f in $files/dir:entry[1 to 30]
            let $fname := xs:string($f/dir:filename)
            let $processed-date := 
                if ( $processed-files/activity:processed[@file = $fname] ) then
                    xs:string($processed-files/activity:processed[@file = $fname][1]/@datetime)
                else
                    ""
            order by $fname descending
            return 
                element tr {
                    <xhtml:td>{$fname}</xhtml:td>,
                    if ($processed-date = "") then
                        (
                            <xhtml:td><xhtml:img src="static/images/x.png" /></xhtml:td>,
                            <xhtml:td><xhtml:br /></xhtml:td>,
                            <xhtml:td><xhtml:a href="do-report.xqy?file={$fname}">Process</xhtml:a></xhtml:td>
                        )
                    else
                        (
                            <xhtml:td><xhtml:img src="static/images/check.png" /></xhtml:td>,
                            <xhtml:td>{$processed-date}</xhtml:td>,
                            <xhtml:td><xhtml:a href="do-report.xqy?file={$fname}"><xhtml:b>Re-</xhtml:b>Process</xhtml:a></xhtml:td>
                        )
                }
        }
    </xhtml:table>
    
let $uploadform := 
        <xhtml:div>
            <xhtml:h2>Upload a MARC/XML File</xhtml:h2>
            <xhtml:form method="post" action="do-report.xqy" enctype="multipart/form-data">
                <xhtml:input name="marcxml" type="file" />
                <xhtml:input type="submit" value="Upload" />
            </xhtml:form>
        </xhtml:div>
        

let $html := 
    <xhtml:html>
        <xhtml:head>
            <xhtml:title>NACO Quality Reports - Process CDS Daily Name Files</xhtml:title>
            <xhtml:meta http-equiv="content-type" content="application/xhtml+xml; charset=utf-8"/>
            <!-- CSS -->
            <xhtml:link type="text/css" media="screen" rel="stylesheet" href="/static/css/styles.css"/>
        </xhtml:head>    
        <xhtml:body>
            <xhtml:div id="container">
            <xhtml:div id="content">
                <xhtml:div id="main_body_full">
                    <xhtml:div id="page_head">
                        <xhtml:h1>NACO Quality Reports - Process CDS Daily Name Files</xhtml:h1>
                        <xhtml:br />
                    </xhtml:div>
                    <xhtml:div>
                        { $filestable }
                        <xhtml:br />
                        <xhtml:br />
                        { $uploadform }
                    </xhtml:div>
                </xhtml:div>
            </xhtml:div>
            </xhtml:div>
        </xhtml:body>
    </xhtml:html>

let $html := transmit:removeNSPrefix($html,"xhtml")
return transmit:sendXHTML($html)
