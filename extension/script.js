$(document).ready(function(){
   $('input.search').typeahead({
      name: 'results',
      local: ['timtrueman', 'jake', 'vskarich', 'tom', 'tammy'],
      template: '<p>{{value}}</p>',
      engine: Hogan
    });

    $('.search').bind('typeahead:selected', function(obj, datum, name) {
        chrome.runtime.sendMessage( { person: "Jasdev Singh" } );
    });
});