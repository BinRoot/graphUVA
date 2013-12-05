$(document).ready(function(){
    $('input.search-page').typeahead({
        name: 'results',
        remote: 'http://uvasear.ch/search?q=%QUERY',
        limit: 5,
        template: ['<p>{{name}} {{#email}}<span class="email">- {{email}}{{/email}}</p>',
                   '<p class="details">{{status}}</p>',
                   '<p class="details">{{department}}</p>',
                  ].join(''),
        engine: Hogan
    });

    $('.search-page').on('typeahead:selected', function(obj, datum, name) {
        $.get( "http://uvasear.ch/update?id=" + datum.comp_id, function(data) {});
    });
});