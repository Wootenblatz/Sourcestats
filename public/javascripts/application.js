// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(){
	
	$('a[href^="http://"]')	.attr({ target: "_blank" });

	function smartColumns() {
		
		$("ul.column").css({ 'width' : "100%"});
		
		var colWrap = $("ul.column").width();
		var colNum = Math.floor(colWrap / 200);
		var colFixed = Math.floor(colWrap / colNum);
		
		
		$("ul.column").css({ 'width' : colWrap});
		$("ul.column li").css({ 'width' : colFixed});

		
		
	}	
	
	smartColumns();	

	$(window).resize(function () {
		smartColumns();
		
	}); 
	
		
});
	
