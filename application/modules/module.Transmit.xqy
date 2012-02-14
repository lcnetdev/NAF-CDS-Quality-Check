xquery version "1.0";

(:
:   Module Name: Transmission Functions
:
:   Module Version: 1.0
:
:   Date: 2010 Oct 18
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: xdmp (MarkLogic)
:
:   Xquery Specification: January 2007
:
:   Module Overview:    Provides a set of functions used
:       for transmitting data from the server to a client.
:
:)
   
(:~
:   Provides a set of functions used for transmitting
:   data from the server to a client.  These range from 
:   functions that remove namespace prefixes from XML
:   (for readability) to those that send the proper
:   response headers.
:
:   @author Kevin Ford (kefo@loc.gov)
:   @since October 18, 2010
:   @version 1.0
:)
module namespace    func    = "info:lc/id-modules/transmit#";        

declare namespace   xhtml   = "http://www.w3.org/1999/xhtml";
declare namespace   xdmp    = "http://marklogic.com/xdmp";
declare namespace   rdf     = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace   rdfs    = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace   madsrdf = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   index   = "id_index#";
declare namespace   ri      = "http://id.loc.gov/ontologies/RecordInfo#";
declare namespace   mets    = "http://www.loc.gov/METS/";
declare namespace   owl     = "http://www.w3.org/2002/07/owl#";
declare namespace   marcxml = "http://www.loc.gov/MARC21/slim";
declare namespace   xlink   = "http://www.w3.org/1999/xlink";
declare namespace   skos    = "http://www.w3.org/2004/02/skos/core#";
declare namespace   skosxl  = "http://www.w3.org/2008/05/skos-xl#";
declare namespace   cs      = "http://purl.org/vocab/changeset/schema#";
declare namespace   vs      = "http://www.w3.org/2003/06/sw-vocab-status/ns#";
declare namespace   atom    = "http://www.w3.org/2005/Atom";
declare namespace   opensearch  = "http://a9.com/-/spec/opensearch/1.1/";
declare namespace   dcterms = "http://purl.org/dc/terms/";
declare namespace   at      = "http://purl.org/atompub/tombstones/1.0";
declare namespace   mads    = "http://www.loc.gov/mads/v2";

declare namespace   error   = "http://marklogic.com/xdmp/error";
declare namespace   em      = "URN:ietf:params:email-xml:"; 
declare namespace   rf      = "URN:ietf:params:rfc822:";

(:~
:   This function removes a namespace prefix.  Naturally, you can 
:   only really remove one namespace.
:
:   @param  $xml        node() is the XML
:   @param  $ns         as xs:string is the prefix to remove  
:   @return node without namespace prefix in place
:)
declare function func:removeNSPrefix($xml as node() , $ns as xs:string) as node() {
    let $str := xdmp:quote($xml)
    let $replace1 := fn:replace($str , fn:concat($ns , ':') , '')
    let $replace2 := fn:replace($replace1 , fn:concat('xmlns:', $ns , '='), 'xmlns=')
    let $xml_noNS := xdmp:unquote($replace2)
    return $xml_noNS
};

(:~
:   Sends ATOM XML with proper headers. This would be
:   the last function called, terminating the Xquery.
:
:   @param  $xml        is the XML to be sent  
:   @return http response content type PLUS content
:)
declare function func:sendATOMXML($xml) {
    let $response := (
        xdmp:set-response-content-type("application/atom+xml"),
        xdmp:add-response-header("Cache-Control", "public, max-age=43200"),
        (: '<?xml version="1.0" encoding="utf-8"?>', :)
        $xml
        )
    return $response
};

(:~
:   Sends Javascript to client with proper headers. This would
:   be the last function called, terminating the Xquery.
:
:   @param  $txt        is the text to be sent  
:   @return http response content type PLUS content
:)
declare function func:sendJS($txt) {
    let $response := (
        xdmp:set-response-content-type("text/javascript"),
        xdmp:add-response-header("Cache-Control", "public, max-age=43200"),
        $txt
        )
    return $response
};

(:~
:   Sends JSON to client with proper headers. This would
:   be the last function called, terminating the Xquery.
:
:   @param  $txt        is the text to be sent  
:   @param  $httpuri     is the HTTP URI for the resource. 
:   @return http response content type PLUS content
:)
declare function func:sendJSON($txt , $httpuri as xs:string) {
    let $response := (
        xdmp:set-response-content-type("application/json"),
        xdmp:add-response-header("Cache-Control", "public, max-age=43200"),
        add-uri-header($httpuri),
        $txt
        )
    return $response
};

(:~
:   Sends RDF/XML with proper headers. This would be
:   the last function called, terminating the Xquery.
:
:   @param  $xml        is the XML to be sent  
:   @param  $httpuri     is the HTTP URI for the resource. 
:   @return http response content type PLUS content
:)
declare function func:sendRDFXML($xml, $httpuri as xs:string) {
    let $response := (
        xdmp:set-response-content-type("application/rdf+xml"),
        xdmp:add-response-header("Cache-Control", "public, max-age=43200"),
        (: '<?xml version="1.0" encoding="utf-8"?>', :)
        add-uri-header($httpuri),
        $xml
        )
    return $response
};

(:~
:   Sends Text to client with proper headers. This would
:   be the last function called, terminating the Xquery.
:
:   @param  $txt        is the text to be sent  
:   @param  $httpuri     is the HTTP URI for the resource. 
:   @return http response content type PLUS content
:)
declare function func:sendText($txt, $httpuri as xs:string) {
    let $response := (
        xdmp:set-response-content-type("text/plain"),
        xdmp:add-response-header("Cache-Control", "public, max-age=43200"),
        add-uri-header($httpuri),
        $txt
        )
    return $response
};

(:~
:   Sends TSV to client with proper headers. This would
:   be the last function called, terminating the Xquery.
:
:   @param  $tsv        is the text to be sent  
:   @param  $httpuri     is the HTTP URI for the resource. 
:   @return http response content type PLUS content
:)
declare function func:sendTSV($tsv, $httpuri as xs:string) {
    let $response := (
        xdmp:set-response-content-type("text/tab-separated-values"),
        xdmp:add-response-header("Cache-Control", "public, max-age=43200"),
        add-uri-header($httpuri),
        $tsv
        )
    return $response
};

(:~
:   sendXHTML func that accepts only one parameter.
:   This ensures backwards compatibility for all calls to sendXHTML,
:   of which there are many.  Easier to create this func than to
:   hunt out and add a second param to all calls.
:
:   @param  $html        is the HTML element to be sent  
:   @return http response content-type PLUS content
:)
declare function func:sendXHTML($html as node())
{
    sendXHTML($html, "")
};

(:~
:   Sends XHTML 1.0 with proper headers, DOCTYPE, ETC.
:   This would be the last function called, terminating 
:   the Xquery.
:
:   @param  $html        is the HTML element to be sent
:   @param  $httpuri     is the HTTP URI for the resource.  Should be "" if there is no HTTP URI, such as for the search page.
:   @return http response content-type PLUS content
:)
declare function func:sendXHTML($html as node() , $httpuri as xs:string) {
    (: the mimetype might need special handling depending on browser support - IE might croak :)
    let $namespaces := '
        xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" 
        xmlns:ri="http://id.loc.gov/ontologies/RecordInfo#" 
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
        xmlns:skos="http://www.w3.org/2004/02/skos/core#" 
        xmlns:skosxl="http://www.w3.org/2008/05/skos-xl#" 
        xmlns:owl="http://www.w3.org/2002/07/owl#" 
        xmlns:cs="http://www.w3.org/2003/06/sw-vocab-status/ns#"
        xmlns:dcterms="http://purl.org/dc/terms/"
        '
    let $str := xdmp:quote($html)
    let $replace := fn:replace($str , ':html ' , fn:concat(':html ' , $namespaces))
    let $html := xdmp:unquote($replace)
    let $prefLabel := 
        $html/xhtml:html/xhtml:body//xhtml:div/xhtml:h1/xhtml:span[@property = 'madsrdf:authoritativeLabel skos:prefLabel' and @xml:lang eq 'eq'][1]|
        $html/xhtml:html/xhtml:body//xhtml:div/xhtml:h1/xhtml:span[@property = 'madsrdf:authoritativeLabel skos:prefLabel'][1]
    let $response := (
        xdmp:set-response-content-type("text/html"),
        xdmp:add-response-header("Cache-Control", "public, max-age=43200"),
        if ($prefLabel[1]) then
            xdmp:add-response-header(
                    "X-PrefLabel",
                    $prefLabel[1]
            )
        else (),
        add-uri-header($httpuri),
        (: '<?xml version="1.0" encoding="utf-8"?>', :)
        '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
            "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
        $html/element()
        )
    (: let $response := $html :)
    return $response
};

(:~
:   Sends XHTML 1.0 with proper headers, DOCTYPE, ETC.
:   This would be the last function called, terminating 
:   the Xquery.
:
:   @param  $html        is the HTML element to be sent
:   @param  $httpuri     is the HTTP URI for the resource.  Should be "" if there is no HTTP URI, such as for the search page.
:   @return http response content-type PLUS content
:)
declare function func:sendXHTMLnoCache($html as node()) {
    (: the mimetype might need special handling depending on browser support - IE might croak :)
    let $namespaces := '
        xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" 
        xmlns:ri="http://id.loc.gov/ontologies/RecordInfo#" 
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
        xmlns:skos="http://www.w3.org/2004/02/skos/core#" 
        xmlns:skosxl="http://www.w3.org/2008/05/skos-xl#" 
        xmlns:owl="http://www.w3.org/2002/07/owl#" 
        xmlns:cs="http://www.w3.org/2003/06/sw-vocab-status/ns#"
        xmlns:dcterms="http://purl.org/dc/terms/"
        '
    let $str := xdmp:quote($html)
    let $replace := fn:replace($str , ':html ' , fn:concat(':html ' , $namespaces))
    let $html := xdmp:unquote($replace)
    let $response := (
        xdmp:set-response-content-type("text/html"),
        xdmp:add-response-header("Cache-Control", "private, no-cache"),
        (: '<?xml version="1.0" encoding="utf-8"?>', :)
        '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
            "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
        $html/element()
        )
    (: let $response := $html :)
    return $response
};

(:~
:   Sends XML 1.0 with proper headers. This would be
:   the last function called, terminating the Xquery.
:
:   @param  $xml        is the XML to be sent  
:   @param  $httpuri     is the HTTP URI for the resource. 
:   @return http response content type PLUS content
:)
declare function func:sendXML($xml , $httpuri as xs:string) {
    let $response := (
        xdmp:set-response-content-type("application/xml"),
        xdmp:add-response-header("Cache-Control", "public, max-age=43200"),
        add-uri-header($httpuri),
        (: '<?xml version="1.0" encoding="utf-8"?>', :)
        $xml
        )
    return $response
};

(:~
:   Formats XML, placing new lines between each element and
:   does format indenting.  Note:  This looses namespaces, 
:   so all prefixes must be in place when calling this function.
:   This doesn't make it perfect, but it achieves what it set out to do,
:   which is break up the XML so that it could be parsed better by third-party
:   tools.  This is surely the tools' fault.
:
:   Now, this is probably not a better mousetrap than inserting
:
:       declare option xdmp:output "indent=yes" ;
:       declare option xdmp:output "indent-untyped=yes" ;
:
:   in page-response.xqy.  The above two lines would pretty-ify
:   the XML, indenting and tabbing each line.  xdmp is necessary
:   on page-response.xqy.
:
:   @param  $xml        is the XML to be sent 
:   @param  $pos        as xs:integer is the level (0 initially) 
:   @return formatted xml node
:)
declare function func:formatXML($xml, $pos) {
    let $ret := 
        for $x in $xml/child::node()[fn:name() or parent::node()[. = xhtml:div]] (: again, dealing with text nodes :)
            let $tabs := 
                for $t in (1 to $pos)
                    return fn:codepoints-to-string(9)
            let $lf := 
                if ($pos gt 0) then 
                    fn:codepoints-to-string(10)
                else ()
            let $el := 
                element {fn:name($x)} {
                    for $a in $x/attribute::*
                        return attribute {fn:name($a)} {$a},
                    let $place := 
                        if ($x/xhtml:div) then
                            $x/xhtml:div
                        else if ($x/child::*) then
                            ( 
                                func:formatXML($x , ($pos+1)) , 
                                fn:codepoints-to-string(10) ,
                                for $t in (1 to $pos)
                                    return fn:codepoints-to-string(9)
                            )
                        else
                            text {$x}
                    return ($place)
                }
            return ($lf,$tabs,$el)
    return 
        if (fn:not($xml/parent::node())) then
            (
                element {fn:name($xml)} {
                    for $a in $xml/attribute::*
                        return attribute {fn:name($a)} {$a},
                    fn:codepoints-to-string(10) ,                        
                    $ret ,
                    fn:codepoints-to-string(10)
                }
            )
        else $ret
};

(:~
:   Generates a X-URI response header, if $httpuri ne "".
:
:   @param  $httpuri        is the HTTP URI, if not blank  
:   @return HTTP response header
:)
declare function add-uri-header($httpuri as xs:string) as item()*
{
        if ($httpuri ne "") then
            xdmp:add-response-header("X-URI", $httpuri)
        else
            ()
};


