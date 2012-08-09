(function($, w, d, undefined) {

function foo () {
	<!--include file="./bar.js"-->
    return 'foo';
}
function bar () {
    return 'bar';
}

alert(foo());
alert(bar());


})(jQuery, window, document);
