$(document).ready(function(){
    $('input.search').typeahead({
        name: 'results',
        remote: 'http://uvasear.ch/search?q=%QUERY',
        limit: 6,
        template: ['<p>{{name}} {{#email}}<span class="email">- {{email}}{{/email}}</p>',
                   '<p class="details">{{status}}</p>',
                   '<p class="details">{{department}}</p>',
                  ].join(''),
        engine: Hogan
    });

    $('.search').on('typeahead:selected', function(obj, datum, name) {
        chrome.runtime.sendMessage({ type: "selection", person: datum.name });
        $.get( "http://uvasear.ch/update?id=" + datum.comp_id, function(data) {});
    });

    $('.search').on('typeahead:closed', function(obj, datum, name) {
        chrome.runtime.sendMessage( { type: "close" });
    });

    setTimeout(function() {
        $('input.search').focus();}, 100);
});

(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','https://ssl.google-analytics.com/ga.js','ga');

ga('create', 'UA-46216711-1', 'extension.com');
ga('send', 'pageview');