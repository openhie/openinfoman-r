import module namespace rscript = "https://github.com/openhie/openinfoman/adapter/r";

declare namespace csd = "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;


(: 
   The query will be executed against the root element of the CSD document.    
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 


rscript:html_result(/.,$careServicesRequest)
