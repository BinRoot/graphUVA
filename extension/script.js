$(document).ready(function(){
    $('input.search').typeahead({
        name: 'results',
        remote: 'http://localhost:5000/search?q=%QUERY',
        limit: 10,
        template: ['<p>{{value}} - {{email}}</p>'].join(''),
        engine: Hogan
    });

    $('.search').on('typeahead:selected', function(obj, datum, name) {
        chrome.runtime.sendMessage( { person: "Jasdev Singh" });
    });
});