xquery version "1.0";

(:
:   Module Name: Do Authorities Report
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
import module namespace constants   = "info:lc/auth-report/constants#" at "constants.xqy";
import module namespace rules       = "info:lc/auth-report/rules#" at "rules.xqy";
import module namespace transmit    = "info:lc/id-modules/transmit#" at "modules/module.Transmit.xqy";

(: NAMESPACES :)
declare namespace xhtml="http://www.w3.org/1999/xhtml"; 
declare namespace l="http://local#";
declare namespace marcxml = "http://www.loc.gov/MARC21/slim";
declare namespace xdmp = "http://marklogic.com/xdmp";
declare namespace activity = "http://local/activity#";
declare namespace em="URN:ietf:params:email-xml:";
declare namespace rf="URN:ietf:params:rfc822:";

(: VARS :)
(:~
:   This variable is for the file
:)
declare variable $action as xs:string := xdmp:get-request-field("action", "");

(:~
:   This variable is for the file
:)
declare variable $file as xs:string := xdmp:get-request-field("file", "");

(:~
:   This variable is for the marcxmldata
:)
declare variable $marcxmldata := xdmp:get-request-field("marcxml" , "");

(:~
:   This variable is for the marcxmldata
:)
declare variable $marcxmldata-filename := xdmp:get-request-field-filename("marcxml" , "");

declare variable $marcxml :=  
        if ($file ne "") then
            xdmp:unquote(xdmp:filesystem-file( fn:concat($constants:DAYNAME_DIR , $file, "/adds_changes") ))
        else
            xdmp:unquote($marcxmldata);
            
declare variable $marcxml-filename :=  
        if ($file ne "") then
            $file
        else
            $marcxmldata-filename;

declare function local:marcxml2text($record) {
    let $textrecord := 
        for $f in $record/marcxml:controlfield|$record/marcxml:datafield
        let $tagANDindicators := fn:concat( $f/@tag , " ", $f/@ind1, $f/@ind2, " " )
        let $subfields := 
            fn:string-join(
                for $sf in $f/marcxml:subfield
                return fn:concat("$", $sf/@code, fn:data($sf)),
                ""
            ) 
        order by $f/@tag
        return
            if ( fn:local-name($f) eq "controlfield" ) then
                fn:concat($tagANDindicators , fn:data($f))
            else
                fn:concat($tagANDindicators , $subfields)
    return 
        fn:concat(
            xs:string($record/marcxml:leader),"
",
            fn:string-join($textrecord, "
"),
"

"
        )
};

let $records-count := count($marcxml/marcxml:collection/marcxml:record)
let $records-new := 
    for $r in $marcxml//marcxml:record
    let $l := xs:string($r/marcxml:leader[1])
    return
        if ( fn:substring($l, 6, 1) eq "n" ) then
            $l
        else
            ()
let $records-new := xs:string(fn:count($records-new))

let $records-modified := 
    for $r in $marcxml//marcxml:record
    let $l := xs:string($r/marcxml:leader[1])
    return
        if ( fn:substring($l, 6, 1) eq "c" ) then
            $l
        else
            ()
let $records-modified := xs:string(fn:count($records-modified))

let $records-deleted := 
    for $r in $marcxml//marcxml:record
    let $l := xs:string($r/marcxml:leader[1])
    return
        if ( fn:substring($l, 6, 1) eq "d" ) then
            $l
        else
            ()
let $records-deleted := xs:string(fn:count($records-deleted))

let $records-deleted-split := 
    for $r in $marcxml//marcxml:record
    let $l := xs:string($r/marcxml:leader[1])
    return
        if ( fn:substring($l, 6, 1) eq "s" ) then
            $l
        else
            ()
let $records-deleted-split := xs:string(fn:count($records-deleted-split))

let $records-deleted-replaced := 
    for $r in $marcxml//marcxml:record
    let $l := xs:string($r/marcxml:leader[1])
    return
        if ( fn:substring($l, 6, 1) eq "x" ) then
            $l
        else
            ()
let $records-deleted-replaced := xs:string(fn:count($records-deleted-replaced))

let $records-obsolete := 
    for $r in $marcxml//marcxml:record
    let $l := xs:string($r/marcxml:leader[1])
    return
        if ( fn:substring($l, 6, 1) eq "o" ) then
            $l
        else
            ()
let $records-obsolete := xs:string(fn:count($records-obsolete))

let $xquery-base := 
      "xquery version '1.0-ml';
       declare namespace l = 'http://local#';
       declare namespace marcxml = 'http://www.loc.gov/MARC21/slim';
       declare variable $l:r as element(marcxml:record) external;
       "


let $testresults := 
    <results>
    {
    
   (: for $rule in $rules:RULES_DAILYNAMES/rule
    let $violations := 
        for $r in $marcxml/marcxml:collection/marcxml:record
        let $xquery := fn:concat($xquery-base, xs:string($rule/tests/test)) 
        let $result := xdmp:eval($xquery, (xs:QName("l:r"), $r))
        return 
            if ($result eq fn:true()) then
                local:marcxml2text($r)
            else
                ()
    let $formatted-violations := 
        if (fn:count($violations) > 0) then
            fn:concat(
"
***" , xs:string($rule/@name), "***",
"
",
                fn:string-join($violations, ""),
"
")
        else ""
    return
        element rule {
            $rule/@name,
            $rule/@desc,
            $rule/@report-results,
            attribute violations {fn:count($violations)},
            $formatted-violations
        } :)

        for $rule in $rules:RULES_DAILYNAMES/rule
        let $violations := 
            for $r in $marcxml/marcxml:collection/marcxml:record
            for $test in $rule/tests/test
            let $xquery := fn:concat($xquery-base, string($test))
            let $result := xdmp:eval($xquery, (xs:QName("l:r"), $r))
            return 
                if ($result eq fn:true()) then
                    local:marcxml2text($r)
                else
                    ()
        let $formatted-violations := 
            if (fn:count($violations) > 0) then
                fn:concat(
                    "&#10;***", xs:string($rule/@name), "***", "&#10;",
                    fn:string-join($violations, ""),
                    "&#10;"
                )
            else ""
        return
            element rule {
                $rule/@name,
                $rule/@desc,
                $rule/@report-results,
                attribute violations {fn:count($violations)},
                $formatted-violations
            }
           
    }
    </results>
        
                
let $results := fn:concat("
Source file: ", $marcxml-filename , "
" , $records-count , " record(s) in source file.
    New:            " , $records-new , "
    Modified:        " , $records-modified , "
    Deleted:          " , $records-deleted , "
    Deleted-Split:     " , $records-deleted-split , "
    Deleted-Replaced:  " , $records-deleted-replaced , "
    Obsoleted:         " , $records-obsolete , "
",
fn:string-join(
    for $tr in $testresults/rule
    let $attachedORinline := 
        if ( xs:integer($tr/@violations) > 0 and xs:integer($tr/@violations) < 11 and $tr/@report-results eq "true") then
            "below"
        else if ( xs:integer($tr/@violations) > 10 and $tr/@report-results eq "true") then
            "attached"
        else 
            "" 
    let $text-matches :=
        if ( xs:integer($tr/@violations) > 0 and $tr/@report-results eq "true") then
            fn:concat( xs:string($tr/@violations) , " record(s) matched the pre-processing pattern: (see " , $attachedORinline , " '" , $tr/@name  , "')" )
        else
            "No record(s) matched the pre-processing pattern:"
    return
        fn:concat($text-matches,"
        ", xs:string($tr/@desc) , "
"),
    ""
)
)

let $problems :=
    fn:string-join(
        for $tr in $testresults/rule
        let $violations := xs:string($tr)
        return
            if ( xs:integer($tr/@violations) > 0 and xs:integer($tr/@violations) < 11 and $tr/@report-results eq "true") then
                $violations
            else
                (),
        "
        
        "
    )    

let $report := 
    fn:concat($results, "



",
$problems)


let $activity-log-save := 
    if (fn:not($constants:DEBUG) and $action eq "email") then
        let $activity-log-file := xdmp:unquote(xdmp:filesystem-file($constants:ACTIVITY_LOG))
        let $new-processed-element := 
            element activity:processed {
                attribute file {$file},
                attribute datetime {fn:current-dateTime()}
            }
        let $activity-log := 
            element activity:activity {
                $new-processed-element,
                $activity-log-file/activity:activity/child::node()
            }
        let $activity-save := xdmp:save($constants:ACTIVITY_LOG,$activity-log)
        return fn:true()
    else
        fn:false()


let $email-newline := "&#13;&#10;"
let $email-boundary := concat("ar", xdmp:random())
let $email-content-type := concat("multipart/mixed; boundary=",$email-boundary)
let $email-attachment-base-filename := fn:concat( 'dlc', fn:substring($file, 3) )
let $email-attachments :=
    fn:string-join(
        for $tr in $testresults/rule
        let $violations := xs:string($tr)
        where xs:integer($tr/@violations) > 10 and $tr/@report-results eq "true"
        return
            let $attachment-fname := fn:replace( xs:string($tr/@name) , " |,|'|=|\.|\$,'" , "")
            let $attachment-fname := xdmp:diacritic-less($attachment-fname)
            let $attachment-fname := fn:concat($email-attachment-base-filename, "-", $attachment-fname , ".txt")
            return
                fn:concat(
                    "Content-Type: text/plain; charset=UTF-8", $email-newline,
                    "Content-Disposition: attachment; filename=", $attachment-fname, $email-newline,
                    "Content-Transfer-Encoding: base64", $email-newline,
                    $email-newline,
                    xdmp:base64-encode(fn:replace($violations, "\n", $email-newline)), $email-newline
                ),
	fn:concat("--",$email-boundary,$email-newline))
        
let $email-content := concat(
    "--",$email-boundary,$email-newline,
	"Content-Type: text/plain; charset=UTF-8", $email-newline,
    $report, $email-newline,
    "--",$email-boundary,$email-newline,
    $email-attachments
)


let $email :=
    if (fn:not($constants:DEBUG) and $action eq "email") then
        xdmp:email(
        <em:Message>
            <rf:message-id>{fn:concat("<", $file, ".", $email-boundary, "@mlinaws>")}</rf:message-id>
            <rf:subject>NACO Quality Report for {$email-attachment-base-filename}</rf:subject>
            <rf:from>
                <em:Address>
                    <em:name>Gardner, Glenn</em:name>
                    <em:adrs>ggar@loc.gov</em:adrs>
                </em:Address>
            </rf:from>
            <rf:to>
            {
                for $address in $constants:MAIL_DAILYNAMES_TO/em:Address
                return $address
            }
            </rf:to>
            <rf:content-type>{$email-content-type}</rf:content-type>
            <em:content xml:space="preserve">
                {$email-content}
            </em:content>
        </em:Message>
        )
    else 
        ()
  
let $html := 
    <xhtml:html>
        <xhtml:head>
            <xhtml:title>NACO Quality Report for  - {$marcxml-filename}</xhtml:title>
            <xhtml:meta http-equiv="content-type" content="application/xhtml+xml; charset=utf-8"/>
            <!-- CSS -->
            <xhtml:link type="text/css" media="screen" rel="stylesheet" href="/static/css/styles.css"/>
        </xhtml:head>    
        <xhtml:body>
            <xhtml:div id="container">
            <xhtml:div id="content">
                <xhtml:div id="main_body_full">
                    <xhtml:div id="page_head">
                        <xhtml:h1>NACO Quality Report for {$marcxml-filename}</xhtml:h1>
                        <xhtml:br />
                    </xhtml:div>
                    <xhtml:div>
                        <xhtml:p><xhtml:a href="/">Back to index</xhtml:a></xhtml:p>
                        <xhtml:p>
                            {
                                if ($constants:DEBUG) then
                                    "You are in debug mode so no email was sent.  This report *would* have been mailed to:"
                                else if ($action eq "view") then
                                    "You requested only to *view* the results.  These were not mailed.  They would have been mailed to:"
                                else 
                                    "The following was emailed to:"
                            }
                            <xhtml:br />
                            <xhtml:br />
                            {
                                for $address in $constants:MAIL_DAILYNAMES_TO/em:Address
                                return 
                                    (
                                    fn:concat(
                                        "      ",
                                        xs:string($address/em:name) , " (" , xs:string($address/em:adrs) , ")"
                                        ),
                                    <xhtml:br />
                                    )
                            }
                            <xhtml:br />
                            {
                                if (count( $testresults/rule[xs:integer(@violations) gt 10] ) ) then
                                    fn:concat( count( $testresults/rule[xs:integer(@violations) gt 10 and @report-results eq "true"] ), " file(s) attached: ",
                                    fn:string-join(
                                        for $tr in $testresults/rule
                                        let $violations := xs:string($tr)
                                        where $tr/@report-results eq "true"
                                        return
                                            if ( xs:integer($tr/@violations) > 10) then
                                                fn:concat($tr/@name , "; ")
                                            else (),
                                                "")
                                    )
                                else ()
                            }
                        </xhtml:p>
                        <xhtml:br />
                        <xhtml:pre>
                            {$report}
                            <!-- {$email-content} -->
                        </xhtml:pre>
                        <xhtml:br />
                        <xhtml:br />
                    </xhtml:div>
                </xhtml:div>
            </xhtml:div>
            </xhtml:div>
        </xhtml:body>
    </xhtml:html>
    
let $html := transmit:removeNSPrefix($html,"xhtml")
return transmit:sendXHTML($html)

