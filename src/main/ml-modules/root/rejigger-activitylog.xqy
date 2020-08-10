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

(: NAMESPACES :)
declare namespace xhtml="http://www.w3.org/1999/xhtml";  
declare namespace xdmp = "http://marklogic.com/xdmp";
declare namespace dir = "http://marklogic.com/xdmp/directory";
declare namespace activity = "http://local/activity#";

(:~
:   This variable is for the file
:)
declare variable $action as xs:string := xdmp:get-request-field("action", "");

let $activity-log-file := xdmp:unquote(xdmp:filesystem-file($constants:ACTIVITY_LOG))
let $newlog := 
    element activity:activity {
        for $a in $activity-log-file/activity:activity/activity:processed
        let $file := xs:string($a/@file)
        let $file := fn:replace($file, ".records.xml", "")
        let $file := fn:replace($file, "d", "")
        let $file := 
            if (
                    fn:string-length($file) eq 8 and 
                    xdmp:castable-as(
                        "http://www.w3.org/2001/XMLSchema",
                        "integer",
                        $file
                    )
                ) then
                $file
            else
                fn:concat("20", $file)
        order by $a/@datetime descending
        return 
            element activity:processed {
                $a/@datetime,
                attribute file {$file}
            }
    }

let $output := 
    if ($action eq "save") then
        (
            xdmp:save($constants:ACTIVITY_LOG, $newlog),
            <output status="saved">{$newlog}</output>
        )
    else
        <output status="view-only">{$newlog}</output>

return $output
