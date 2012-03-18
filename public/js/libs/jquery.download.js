/*
 * --------------------------------------------------------------------
 * jQuery-Plugin - $.download - allows for simple get/post requests for files
 * by Scott Jehl, scott@filamentgroup.com
 * http://www.filamentgroup.com
 * reference article: http://www.filamentgroup.com/lab/jquery_plugin_for_requesting_ajax_like_file_downloads/
 * Copyright (c) 2008 Filament Group, Inc
 * Dual licensed under the MIT (filamentgroup.com/examples/mit-license.txt) and GPL (filamentgroup.com/examples/gpl-license.txt) licenses.
 * --------------------------------------------------------------------

TUT: http://www.filamentgroup.com/lab/jquery_plugin_for_requesting_ajax_like_file_downloads/
$.download('/export.php','filename=mySpreadsheet&format=xls&content=' + spreadsheetData );
 */
 
jQuery.download = function(url, data, method){
	//url and data options required
	if( url && data ){ 
		//data can be string of parameters or array/object
		data = typeof data == 'string' ? data : jQuery.param(data);
		//split params into form inputs
		var inputs = '';
		jQuery.each(data.split('&'), function(){ 
			var pair = this.split('=');
			//inputs+='<input type="hidden" name="'+ pair[0] +'" value="'+ backslashQuote(pair[1]) +'" />'; 
			inputs+='<input type="hidden" name="'+ pair[0] +'" '+ "value='"+ backslashQuote(pair[1]) +"' />"; 
		});
		//send request
		jQuery('<form action="'+ url +'" method="'+ (method||'post') +'">'+inputs+'</form>')
		.appendTo('body').submit().remove();
	};
};

function backslashQuote(str){
	//str =  str.replace(/\"/g,'\"');
	//return str =  str.replace(/\"/g,'\""');//str.replace(/\'/g,"\\'");
	 //str=str.replace(/\'/g,"\'\'");
//	str=str.replace(/\"/g,'\\"');
	//return (str + '').replace(/[\\"']/g, '\\$&').replace(/\u0000/g, '\\0');
	str = escape(str);
	return str;
	
}






