openinfoman-r
=============

OpenInfoman CSD Adapater for R statistics program 

Prerequisites
=============

Assumes that you have installed BaseX and OpenInfoMan according to:
> https://github.com/openhie/openinfoman/wiki/Install-Instructions

and the OpenInfoMan CSV adapter
> https://github.com/openhie/openinfoman-csv

and the FunctX XQuery Library:
<pre>
 basex -Vc "REPO INSTALL http://files.basex.org/modules/expath/functx-1.0.xar"
</pre>

Directions
==========
<pre>
cd ~/
git clone https://github.com/openhie/openinfoman-r
cd ~/openinfoman-r/repo
basex -Vc "REPO INSTALL openinfoman_r_adapter.xqm"
cd ~/basex/resources/stored_query_definitions
ln -sf ~/openinfoman-r/resources/stored_query_definitions/* .
cd ~/basex/webapp/
ln -s ~/openinfoman-r/webapp/openinfoman_r_adapter_bindings.xqm 
</pre>

