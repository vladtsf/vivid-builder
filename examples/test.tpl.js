(function($, w, d) {
	
	include ('./foo.js');
	include ('./bar.js')

	alert(foo());
	alert(bar());


})(jQuery, window, document);
