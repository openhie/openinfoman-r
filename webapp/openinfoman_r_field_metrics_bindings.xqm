module namespace page = 'http://basex.org/modules/web-page';

import module namespace rscript = "https://github.com/openhie/openinfoman/adapter/r";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
declare namespace html = "http://www.w3.org/1999/xhtml";
import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";

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
	  
	    <a href="{$csd_webconf:baseurl}/CSD/adapter/r/{$analysis_name}/{$doc_name}">{string($doc_name)}</a>
	  </li>
	}
      </ul>

(:    let $auto_links := 
      for $doc_name in csd_dm:registered_documents($csd_webconf:db)      
      return 
        for $analysis_func in csr_proc:stored_functions($csd_webconf:db)[@uuid = $analsyis_name]
	let $slink:= concat($csd_webconf:baseurl , "CSD/adapter/r/" , $analysis_func/@uuid, "/" , $doc_name)
        let $short_name := $analysis_func/csd:description
	let $title := concat($short_name, " : "  ,$doc_name)
	where rscript:is_analytic_function($analysis_func/@uuid)
	return 
          <link rel="search" href="{$slink}"  type="application/rstat+xml" title="{$title}" /> :)
   return page:wrapper($analyses)
  else
   let $contents := 
   <pre class='bodycontainer scrollable pull-left' style='overflow:scroll;font-family: monospace;white-space: pre;'>
     {
       csr_proc:get_function_definition($csd_webconf:db,$analysis_name) 
     }
   </pre>
   return  page:wrapper(("Invalid Analysis",$contents))
};



declare
  %rest:path("/CSD/adapter/r/{$analysis_name}/{$doc_name}")
  %rest:GET
  %output:method("xhtml")
  function page:show_analysis_on_docs($analysis_name,$doc_name)
{ 
  ()
};



(:


declare updating
  %rest:path("/CSD/r_field_metrics/field/delete/{$name}")
  %rest:GET
  function page:delete($name)
{ 
   (
   oi_rfm:remove_metric_field($db,$name)
   ,db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/r_field_metrics")))
   )

};


declare updating
  %rest:path("/CSD/r_field_metrics/field/update")
  %rest:query-param("name", "{$name}")
  %rest:query-param("xpath", "{$xpath}")
  %rest:POST
  function page:delete($name,$xpath)
{ 
   (
   if ($xpath and $name) then 
     oi_rfm:add_metric_field($db,$name,$xpath)
   else ()
   ,db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/r_field_metrics")))
   )

};




declare updating
  %rest:path("/CSD/r_field_metrics/dump/publish/{$doc_name}")
  %rest:GET
  function page:publish($doc_name)
{ 
   (
   oi_rfm:publish_dump($db,$doc_name)
   ,db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/r_field_metrics")))
   )
};


declare
  %rest:path("/CSD/r_field_metrics/dump/download/{$doc_name}")
  %rest:GET
  function page:download($doc_name)
{ 
   oi_rfm:get_dump($db,$doc_name)
};



declare updating
  %rest:path("/CSD/r_field_metrics/dump/delete/{$doc_name}")
  %rest:GET
  function page:delete($doc_name)
{ 
   (
   oi_rfm:delete_dump($db,$doc_name)
   ,db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/r_field_metrics")))
   )

};

:)


declare function page:wrapper($content) {
 <html>
  <head>

    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>
    

    <link rel="stylesheet" type="text/css" media="screen"   href="{$csd_webconf:baseurl}static/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css"/>

    <script src="https://code.jquery.com/jquery.js"/>
    <script src="{$csd_webconf:baseurl}static/bootstrap/js/bootstrap.min.js"/>
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


