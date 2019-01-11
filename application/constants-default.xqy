xquery version "1.0";

(:
:   Module Name: Contants file
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
:   Module Overview:     Constants for the little app.
:
:)

(:~
:   Constants for the little app.
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
:   Activity Log - should be *absolute* path
:   This needs to be writeable
:)
declare variable $ACTIVITY_LOG as xs:string := "logs/activity.xml";

(:~
:   DAYNAME Directory - should be *absolute* path
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
        

