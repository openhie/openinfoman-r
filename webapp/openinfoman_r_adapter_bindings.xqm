module namespace page = 'http://basex.org/modules/web-page';

import module namespace rscript = "https://github.com/openhie/openinfoman/adapter/r";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
import module namespace oi_csv = "https://github.com/openhie/openinfoman/adapter/csv";

declare namespace html = "http://www.w3.org/1999/xhtml";


declare namespace csd = "urn:ihe:iti:csd:2013";


declare function page:redirect($redirect as xs:string) as element(restxq:redirect)
{
  <restxq:redirect>{ $redirect }</restxq:redirect>
};

declare function page:nocache($response) {
(<http:response status="200" message="OK">  

  <http:header name="Cache-Control" value="must-revalidate,no-cache,no-store"/>
</http:response>,
$response)
};




(:Supposed to be linked into header of a web-page, such as the OpenHIE Health Worker Registry Management Interface :)
declare
  %rest:path("/CSD/adapter/r/{$analysis_name}")
  %rest:GET
  %output:method("xhtml")
  function page:show_analyses_on_docs($analysis_name) 
{ 
  if ( rscript:is_analysis_function($analysis_name)) then 
    let $analyses := 
      <ul>
        {
  	  for $doc_name in csd_dm:registered_documents($csd_webconf:db)      
	  return
  	  <li>
	  
	    <a href="{$csd_webconf:baseurl}CSD/adapter/r/{$analysis_name}/{$doc_name}">{string($doc_name)}</a>
	  </li>
	}
      </ul>

   let $contents :=
      <div class='contatiner'>
	<a href="{$csd_webconf:baseurl}CSD/adapter/r">R Adapters</a>
        {$analyses}
      </div>
   return csd_webconf:wrapper($contents)
  else
  let $function := csr_proc:get_function_definition($csd_webconf:db,$analysis_name)
  let $contents := 
  <div class='container'>
   <p>
     Invalid Analysis ({$analysis_name})
   </p>
   <p>
     <pre class='bodycontainer scrollable pull-left' style='overflow:scroll;font-family: monospace;white-space: pre;'>
       {
	 $function
       }
     </pre>
   </p>
  </div>
  return  csd_webconf:wrapper($contents)
};



declare
  %rest:path("/CSD/adapter/r/{$analysis_name}/{$doc_name}/run/exec")
  %output:method("xhtml")
  %rest:POST
(:  %output:method("application/csv") :)
  function page:run_script($analysis_name,$doc_name)
{
  let $requestParams := 
    <csd:requestParams function="{$analysis_name}" resource="{$doc_name}" base_url="{$csd_webconf:baseurl}"/> 	  	  
  let $doc := csd_dm:open_document($csd_webconf:db,$doc_name)
  let $contents := csr_proc:process_CSR_stored_results($csd_webconf:db, $doc,$requestParams)
  return $contents
};

declare
  %rest:path("/CSD/adapter/r/{$analysis_name}/{$doc_name}/run")
  %output:method("xhtml")
  %rest:GET
(:  %output:method("application/csv") :)
  function page:run_script_get($analysis_name,$doc_name)
{
  let $contents := <div class='container'>
    <p>Analysis: 	    <a href="{$csd_webconf:baseurl}CSD/adapter/r/{$analysis_name}">{$analysis_name}</a></p>
    <p>Resource Document: <a href="{$csd_webconf:baseurl}CSD/adapter/r/{$analysis_name}/{$doc_name}">{$doc_name}</a></p>
    <form method='post' action="{$csd_webconf:baseurl}CSD/adapter/r/{$analysis_name}/{$doc_name}/run/exec"  enctype="multipart/form-data">
      <input type='submit' value='Run Script'/>
    </form>
  </div>
  return csd_webconf:wrapper($contents)
   
};




declare
  %rest:path("/CSD/adapter/r/{$analysis_name}/{$doc_name}/get_dataframe")
  %rest:GET
  function page:get_dataframe($analysis_name,$doc_name)
{ 
  let $df := rscript:get_dataframe($analysis_name,$doc_name) 
  return  
    if ($df  = '1' )
    then 
      (
      <rest:response>
	<http:response status="200" >
	  <http:header name="Content-Type" value="text/csv; charset=utf-8"/>
	  <http:header name="Content-Disposition" value="inline; filename='dataframe.csv'"/>
	</http:response>
      </rest:response>
      ,$df 
      )
    else
       (
       <rest:response>
	 <http:response status="200" >
	    <http:header name="Content-Type" value="text/html; charset=utf-8"/>
	 </http:response>
       </rest:response>
       ,
       let $contents:=
	  <div class='container'>
	    No Data Frame has been cached
	    <a href="{$csd_webconf:baseurl}CSD/adapter/r/{$analysis_name}/{$doc_name}">Return</a>
	    <p>
	      Temp directory is: {file:temp-dir()}
	    </p>
	  </div>
       return page:wrapper_light($contents)
     )
 
    
  
};




declare
  %rest:path("/CSD/adapter/r/{$analysis_name}/{$doc_name}/create_dataframe")
  %output:method("xhtml")
  %rest:GET
(:  %output:method("application/csv") :)
  function page:create_dataframe($analysis_name,$doc_name)
{ 
  let $requestParams :=   <csd:requestParams function="{$analysis_name}" resource="{$doc_name}"/>
  let $csd_doc := csd_dm:open_document($csd_webconf:db,$doc_name) 
  let $res := rscript:create_dataframe($csd_doc,$requestParams)
  let $contents := 
    if ($res) 
    then  
	  <div class='container'>
	    Data Frame has been cached 
	    <a href="{$csd_webconf:baseurl}CSD/adapter/r/{$analysis_name}/{$doc_name}">Return</a>
	    <p>{$res}</p>
	  </div>
    else
	  <div class='container'>
	    No Data Frame has been cached
	    <a href="{$csd_webconf:baseurl}CSD/adapter/r/{$analysis_name}/{$doc_name}">Return</a>
	  </div>

  return 
       (
       <rest:response>
	 <http:response status="200" >
	 </http:response>
       </rest:response>
       ,
       csd_webconf:wrapper($contents)
     )
 
    
  
};


declare
  %rest:path("/CSD/adapter/r/{$analysis_name}/{$doc_name}")
  %rest:GET
  %output:method("xhtml")
  function page:show_analysis_on_docs($analysis_name,$doc_name)
{ 
let $contents := 
<div class='container'>
  <ul>
    <p>Analysis: 	    <a href="{$csd_webconf:baseurl}CSD/adapter/r/{$analysis_name}">{$analysis_name}</a></p>
    <li>
      <a href="{$csd_webconf:baseurl}CSD/adapter/r/{$analysis_name}/{$doc_name}/create_dataframe">
       Create Data Frame
      </a>
    </li>
    <li>
      <a href="{$csd_webconf:baseurl}CSD/adapter/r/{$analysis_name}/{$doc_name}/get_dataframe">
       Get Data Frame
      </a>
    </li>
    <li>
      <a href="{$csd_webconf:baseurl}CSD/adapter/r/{$analysis_name}/{$doc_name}/run">
        Run R script
      </a>
    </li>
    <li> 
      {
	let $requestParams:=
	   <csd:requestParams function="{$analysis_name}" resource="{$doc_name}" base_url="{$csd_webconf:baseurl}"/>
	let $csd_doc := csd_dm:open_document($csd_webconf:db,$doc_name) 

	return <pre>{oi_csv:get_serialized($csd_doc,$requestParams)}</pre>
      }
    </li>
  </ul>
</div>
return csd_webconf:wrapper($contents)
};


declare function page:wrapper_light($content) {
 <html >
  <head>

    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>

  </head>
  <body>  
    <div class="navbar navbar-inverse navbar-static-top">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="{$csd_webconf:baseurl}CSD">OpenInfoMan</a>
        </div>
      </div>
    </div>
    <div class='container'> {$content}</div>
  </body>
 </html>

};


