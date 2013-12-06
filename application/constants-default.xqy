xquery version "1.0";

(:
:   Module Name: Vars
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

module namespace constants = 'info:lc/auth-report/constants#';

(: NAMESPACES :)
declare namespace em="URN:ietf:params:email-xml:";

(:~
:   This variable is used by the app to determine whether it is
:   in production or development.  If set to "true" no emails will be sent.
:)
declare variable $DEBUG as xs:boolean := fn:true();

(:~
:   Activity Log - should be absolute path
:   This needs to be writeable
:)
declare variable $ACTIVITY_LOG as xs:string := "logs/activity.xml";

(:~
:   DAYNAME Directory - should be aboluste path
:)
declare variable $DAYNAME_DIR as xs:string := "";

(:~
:   The daily-name quality report will be mailed to these individuals.  
:   Repeat em:Address as needed.
:)
declare variable $MAIL_DAILYNAMES_TO as element() := 
        <to>
            <em:Address>
                <em:name>Recipient</em:name>
                <em:adrs>recipient@example.org</em:adrs>
            </em:Address>
        </to>;
        

declare variable $RULES_DAILYNAMES as element() := 
    <rules>
        <rule name="Spacing Grave" desc="AND XXX=`" report-results="true">
            <tests>
                <test>fn:matches( fn:string-join($l:r//text(), " "), '`')</test>
            </tests>
        </rule>
        <rule name="040 $b NOT eng" desc="040 $b NOT eng" report-results="true">
            <tests>
                <test>xs:boolean($l:r/marcxml:datafield[@tag="040"]/marcxml:subfield[@code="b"]!="eng")</test>
            </tests>
        </rule>
        <rule name="Number Sign" desc="AND XXX=#" report-results="true">
            <tests>
                <test>fn:matches( fn:string-join($l:r//text(), " "), '#')</test>
            </tests>
        </rule>
        <rule name="Superscript Zero" desc="AND XXX=⁰" report-results="true">
            <tests>
                <test>fn:matches( fn:string-join($l:r//text(), " "), '⁰')</test>
            </tests>
        </rule>
        <rule name="Double Curly Quotes" desc="AND XXX=” OR XXX=“" report-results="true">
            <tests>
                <test>
                    if (fn:matches( fn:string-join($l:r//text(), " "), '“') or fn:matches( fn:string-join($l:r//text(), " "), '”')) then
                        fn:true()
                    else
                        fn:false()
                </test>
            </tests>
        </rule>
        <rule name="Leader 17=o" desc="AND 000/17=o" report-results="true">
            <tests>
                <test>
                    if ( fn:substring( xs:string($l:r/marcxml:leader), 17 + 1, 1) eq "o" ) then
                        fn:true()
                    else
                        fn:false()
                </test>
            </tests>
        </rule>
        <!--
        Disabled for now - 8 March 2013 - because of on-going batch RDA changes.
        <rule name="RDA Records" desc="RDA Records" report-results="true">
            <tests>
                <test>
                    if ( 
                            $l:r/marcxml:datafield[@tag="040"]/marcxml:subfield[@code="e"] = 'rda' or
                            $l:r/marcxml:datafield[@tag="046"]/marcxml:subfield or
                            $l:r/marcxml:datafield[fn:starts-with(@tag,'3')]/marcxml:subfield
                           ) then
                        fn:true()
                    else
                        fn:false()
                </test>
            </tests>
        </rule>
        -->
        <rule name="040 $e AND 008/10=c,a,b,d" desc="040 $e AND 008/10=c,a,b,d" report-results="true">
            <tests>
                <test>
                    let $field008-10 := fn:substring( xs:string($l:r/marcxml:controlfield[@tag="008"][1]) , 10 + 1 , 1)
                    return
                        if ( 
                            $l:r/marcxml:datafield[@tag="040"]/marcxml:subfield[@code="e"] and 
                            $field008-10 eq "a|b|d|n"
                           ) then
                        fn:true()
                    else
                        fn:false()
                </test>
            </tests>
        </rule>
        <rule name="008/10=z but NO 040 $e" desc="008/10=z but NO 040 $e" report-results="true">
            <tests>
                <test>
                    let $field008-10 := fn:substring( xs:string($l:r/marcxml:controlfield[@tag="008"][1]) , 10 + 1 , 1)
                    return
                        if ( 
                            $field008-10 eq "z" and
                            fn:not($l:r/marcxml:datafield[@tag="040"]/marcxml:subfield[@code="e"]) 
                           ) then
                        fn:true()
                    else
                        fn:false()
                </test>
            </tests>
        </rule>
        <rule name="If 008/10='z' then 008/32 cannot equal 'b'" desc="If 008/10='z' then 008/32 cannot equal 'b'" report-results="true">
            <tests>
                <test>
                    let $field008-10 := fn:substring( xs:string($l:r/marcxml:controlfield[@tag="008"][1]) , 10 + 1 , 1)
                    let $field008-32 := fn:substring( xs:string($l:r/marcxml:controlfield[@tag="008"][1]) , 32 + 1 , 1)
                    return
                        if ( 
                            $field008-10 eq "z" and $field008-32 eq "b"
                           ) then
                        fn:true()
                    else
                        fn:false()
                </test>
            </tests>
        </rule>
        <rule name="Non-Latin in 1XX" desc="Non-Latin in 1XX" report-results="true">
            <tests>
                <test>
                    let $field1XXs := fn:string-join( $l:r/marcxml:datafield[fn:starts-with(@tag,'1')]/marcxml:subfield/text() , " ")
                    let $codepoints := fn:string-to-codepoints($field1XXs)
                    let $hits := 
                        for $cp in $codepoints
                        (: where xs:integer($cp) gt xs:integer("4351") :)
                        return 
                            (:
                            if ( ($cp gt 879) and ($cp lt 7414)) then
                                $cp
                            else 
                                ()
                            :)
                            (:
                            879-1023 is Greek and Coptic (0370-03FF) (xCE, xCF)
                            1024-1279 is Cyrillic (0400-04FF) (xD0 XD1 xD2), but Larry stopped at xD1, the end of which is 1151 (end of xD2 is 1215) 
                            xD6 is 1408 to 1471; xD7 is 1472 to 1535, xD8 is 1536 to 1599; xD9 is 1600 to 1663; xDA is 1664 to 1727; xDB is 1728 to 1791 
                            xE3 begins at 12288; xED ends at 57343
                            :)
                            if (
                                ($cp gt 878 and $cp lt 1216) or
                                ($cp gt 1023 and $cp lt 1152) or
                                ($cp gt 1407 and $cp lt 1792) or
                                ($cp gt 12287 and $cp lt 57344)
                               ) then
                               $cp
                            else
                                ()
                        
                    return
                        if ( fn:count($hits) > 0 ) then
                            fn:true()
                        else
                            fn:false()
                </test>
            </tests>
        </rule>
        <rule name="Non-Latin in 4XX/67X" desc="Non-Latin in 4XX/67X">
            <tests>
                <test>
                    let $field4XXs := fn:string-join( $l:r/marcxml:datafield[fn:starts-with(@tag,'4') or fn:starts-with(@tag,'67')]/marcxml:subfield/text() , " ")
                    let $codepoints := fn:string-to-codepoints($field4XXs)
                    let $hits := 
                        for $cp in $codepoints
                        (: where xs:integer($cp) gt xs:integer("4351") :)
                        return 
                            (: 687 is the end of the international phonetic alphabet (02AF) :)
                            (: 879 is the end of the diacritics (036F) :)
                            (: 768 is the beginning of diacrtics (0300) :)
                            
                            
                            
                            (: if ( ($cp gt 687) and ($cp lt 7000)) then :) (: 687 is the end of hte international phonetic alphabet :)
                            (: if ( ($cp gt 687) and ($cp lt 7414)) then :)
                            (: It really should be this simple.  If it is non-Latin, it should be greater than 879.  Period. :)
                            (: if ( ($cp gt 879) ) then :)
                            (:
                            if ( 
                                $cp lt 591 or 
                                ($cp gt 7680 and $cp lt 7935) or 
                                ($cp gt 11360 and $cp lt 11380) or 
                                ($cp gt 42784 and $cp lt 43007) or 
                                ($cp gt 64256 and $cp lt 64335) or 
                                ($cp gt 65280 and $cp lt 65519) or
                                ($cp gt 60000 and $cp lt 63747)
                               ) then
                                ()
                            else 
                                $cp
                            :)
                            (:
                            879-1023 is Greek and Coptic (0370-03FF) (xCE, xCF)
                            1024-1279 is Cyrillic (0400-04FF) (xD0 XD1 xD2), but Larry stopped at xD1, the end of which is 1151 (end of xD2 is 1215 
                            xD6 is 1408 to 1471; xD7 is 1472 to 1535, xD8 is 1536 to 1599; xD9 is 1600 to 1663; xDA is 1664 to 1727; xDB is 1728 to 1791 
                            xE3 begins at 12288; xED ends at 57343
                            :)
                            if (
                                ($cp gt 878 and $cp lt 1023) or
                                ($cp gt 1023 and $cp lt 1152) or
                                ($cp gt 1407 and $cp lt 1792) or
                                ($cp gt 12287 and $cp lt 57344)
                               ) then
                               $cp
                            else
                                ()                             
                                        
                    return
                        if ( fn:count($hits) > 0 ) then
                            fn:true()
                        else
                            fn:false()
                </test>
            </tests>
        </rule>
        <rule name="No 667, or no 'Non-Latin' in 667" desc="No 667, or no 'Non-Latin' in 667" report-results="true">
            <tests>
                <test>
                    let $field4XXs := fn:string-join( $l:r/marcxml:datafield[fn:starts-with(@tag,'4') or fn:starts-with(@tag,'67')]/marcxml:subfield/text() , " ")
                    let $field667s := fn:string-join($l:r/marcxml:datafield[@tag="667"]/marcxml:subfield, " ") 
                    let $codepoints := fn:string-to-codepoints($field4XXs)
                    let $hits := 
                        for $cp in $codepoints
                        (: where xs:integer($cp) gt xs:integer("4351") :)
                        return 
                            (:
                            879-1023 is Greek and Coptic (0370-03FF) (xCE, xCF)
                            1024-1279 is Cyrillic (0400-04FF) (xD0 XD1 xD2), but Larry stopped at xD1, the end of which is 1151 (end of xD2 is 1215 
                            xD6 is 1408 to 1471; xD7 is 1472 to 1535, xD8 is 1536 to 1599; xD9 is 1600 to 1663; xDA is 1664 to 1727; xDB is 1728 to 1791 
                            xE3 begins at 12288; xED ends at 57343
                            :)
                            if (
                                (
                                    ($cp gt 878 and $cp lt 1024) or
                                    ($cp gt 1023 and $cp lt 1152) or
                                    ($cp gt 1407 and $cp lt 1792) or
                                    ($cp gt 12287 and $cp lt 57344)
                                 ) and (
                                    fn:not($l:r/marcxml:datafield[@tag="667"]/marcxml:subfield) or
                                    fn:not( fn:matches($field667s, "non-latin", "i") )
                                 )
                               ) then
                               $cp
                            else  
                                () 
                    return
                        if ( fn:count($hits) > 0 ) then
                            fn:true()
                        else
                            fn:false()
                </test>
            </tests>
        </rule>
    </rules>;
        
