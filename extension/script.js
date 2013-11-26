$(document).ready(function(){
    $('input.search').typeahead({
        name: 'results',
        remote: 'http://localhost:5000/search?q=%QUERY',
        limit: 10,
        template: ['<p>{{value}}</p>',
                   '<p>{{email}}</p>',
                   '<p class="email">{{phoneNumber}}</p>',
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