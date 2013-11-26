$(document).ready(function(){
   $('input.search').typeahead({
      name: 'results',
      local: ['timtrueman', 'jake', 'vskarich', 'tom', 'tammy'],
      template: '<p>{{value}}</p>',
      engine: Hogan
    });

    $('.search').on('typeahead:selected', function(obj, datum, name) {
        alert("click event recieved");
        chrome.runtime.sendMessage( { person: "Jasdev Singh" });
    });
});