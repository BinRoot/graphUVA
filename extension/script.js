$(document).ready(function(){
    $('input.search').typeahead({
        name: 'results',
        remote: 'http://localhost:5000/search?q=%QUERY',
        limit: 6,
        template: ['<p>{{value}} {{#email}}<span class="email">- {{email}}{{/email}}</p>',
                   '<p class="details">{{status}}</p>',
                   '<p class="details">{{department}}</p>',
                  ].join(''),
        engine: Hogan
    });

    $('.search').on('typeahead:selected', function(obj, datum, name) {
        chrome.runtime.sendMessage( { type: "selection", person: datum.value });
    });

    $('.search').on('typeahead:closed', function(obj, datum, name) {
        chrome.runtime.sendMessage( { type: "close" });
    });
});