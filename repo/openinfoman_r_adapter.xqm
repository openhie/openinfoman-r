(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/openhie/openinfoman
:
:)
module namespace rscript = "https://github.com/openhie/openinfoman/adapter/r";

import module namespace oi_csv = "https://github.com/openhie/openinfoman/adapter/csv";
import module namespace csv = "http://basex.org/modules/csv";
import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
import module namespace proc = "http://basex.org/modules/proc ";
import module namespace file = "http://expath.org/ns/file";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";

declare namespace csd = "urn:ihe:iti:csd:2013";

declare variable $rscript:temp_dir := concat(file:temp-dir() , "/openinfoman/R_adapter");
declare variable $rscript:script_dir := concat($rscript:temp_dir , "/scripts");
declare variable $rscript:df_dir := concat($rscript:temp_dir , "/dataframes");
declare variable $rscript:r_exec := concat(file:current-dir() ,"../repo/evalRscript.sh");


declare function rscript:is_analysis_function($analysis_name) {
  let $function := csr_proc:get_function_definition($csd_webconf:db,$analysis_name)
  let $adapter := $function//csd:extension[ @type='r' and @urn='urn:openhie.org:openinfoman:adapter']
  let $desc := $function//csd:extension[ @type='description' and @urn='urn:openhie.org:openinfoman:adapter:r']
  let $script := $function//csd:extension[ @type='definition' and @urn='urn:openhie.org:openinfoman:adapter:r']
(:  return (exists($desc)  and exists($script)) :)
  return $adapter
};



declare function rscript:echo_result($csd_doc,$requestParams)
{
  let $res0 := rscript:create_dataframe($csd_doc,$requestParams)
  return rscript:execute_script($requestParams)
};

declare function rscript:html_result($csd_doc,$requestParams) 
{
  let $res0 := rscript:create_dataframe($csd_doc,$requestParams)
  let $res1 := rscript:execute_script($requestParams)
  let $output := $res1//output/text()
  let $code := $res1//code
  let $error := $res1//error
  return
    if (exists($code) and (string($code) = "0"))
    then
      <span>
        <h1>Results</h1>
        <pre>{$output}</pre>
      </span>
    else 
      <span>
        "Unable to execute script: " {$code} 
	<p class='error'>{$error}</p>
      </span>
};




declare function rscript:html_table_result($csd_doc,$requestParams) 
{
  let $res0 := rscript:create_dataframe($csd_doc,$requestParams)
  let $res1 := rscript:execute_script($requestParams)
  let $output := $res1//output/text()
  let $code := $res1//code
  let $error := $res1//error
  return
    if (exists($code) and (string($code) = "0"))
    then
      let $csv := csv:parse($output)
      let $header := $csv//record[1]
      let $rows := $csv//record[position() > 1]
      let $datauri := "data:text/csv;charset=UTF-8," || encode-for-uri($output)
      return 
        <span>
          <h1>Results</h1>
	  <table>
	    <tr>
	     { for $head in $header/* return <th>{$head/text()}</th>}
	    </tr>
	    {
	      for $row in $rows
	      return 
	      <tr>
		{ for $val in $row/* return <td>{$val/text()}</td>}
	      </tr>
	    }
	    
	  </table>
          <a href="{$datauri}">Download as CSV</a>
	</span>
    else 
      <span>
        "Unable to execute script: " {$code} 
	<p class='error'>{$error}</p>
      </span>
};


declare function rscript:get_dataframes() 
{
  file:list(concat($rscript:df_dir,false(),"*/*.dataframe"))
};

declare function rscript:delete_dataframe($analysis_name,$doc_name) {
  let $df_src := concat($rscript:df_dir,"/",$analysis_name , "/" , $doc_name , ".dataframe")
  return if (file:is-file($df_src)) then file:delete($df_src) else ()
};

declare function rscript:get_dataframe($analysis_name,$doc_name) {
  let $df_src := concat($rscript:df_dir,"/",$analysis_name , "/" , $doc_name , ".dataframe")
  return if (file:is-file($df_src)) then file:read-text($df_src) else ()
};



declare function rscript:create_dataframe($csd_doc,$requestParams)
 {
  let $analysis_name := string($requestParams/@function)
  let $doc_name := string($requestParams/@resource)
  let $df_dir := concat($rscript:df_dir , "/" , $analysis_name)
  let $df_src := concat($df_dir, "/" , $doc_name , ".dataframe")
  let $csv := oi_csv:get_serialized($csd_doc,$requestParams)
  let $res0 := file:create-dir($df_dir)
  let $res1 := file:write-text($df_src,$csv)
  let $res1 := file:write($df_src || '.xml' ,oi_csv:get($csd_doc,$requestParams))
  return $df_src

};

declare function rscript:get_script($analysis_name) {
    let $function := csr_proc:get_function_definition($csd_webconf:db,$analysis_name)
    let $src := string($function//csd:extension[ @type='definition' and @urn='urn:openhie.org:openinfoman:adapter:r'])
    return $src
};




declare function rscript:execute_script($requestParams) 
{
  let $analysis_name := string($requestParams/@function)
  let $doc_name := string($requestParams/@resource)
  let $script := rscript:get_script($analysis_name)
  let $df_src := concat($rscript:df_dir,"/",$analysis_name , "/" , $doc_name , ".dataframe")
  let $r_src := concat($rscript:script_dir,"/",$analysis_name , ".R")
  let $res0 := file:create-dir($rscript:script_dir)

  return 
    if ($script and file:is-file($df_src) ) then
      let $res1 := file:create-dir($rscript:temp_dir)
      let $res2 := file:write-text($r_src,$script)
      let $r_out :=   proc:execute($rscript:r_exec, ($df_src,$r_src))
      return $r_out
    else ()

};





