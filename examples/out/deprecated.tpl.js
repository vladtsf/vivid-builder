(function($, w, d) {
	
function foo () {
	include("./bar.js")
    return 'foo';
}
function bar () {
    return 'bar';
}

	alert(foo());
	alert(bar());


})(jQuery, window, document);
