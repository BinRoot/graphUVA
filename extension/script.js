chrome.runtime.onMessage.addListener(
    function(request, sender, sendResponse) {
        if(request.type === "selection"){
            $('.uva-search').val(request.comp_id);

            var copyDiv = document.getElementsByClassName('uva-search')[0];
            copyDiv.focus();

            document.execCommand('SelectAll');
            document.execCommand("Copy", false, null);
            window.setTimeout(window.close, 10);
        }
});

$(document).ready(function(){
    $('input.uva-search').typeahead({
        name: 'results',
        remote: 'http://uvasear.ch/search?q=%QUERY',
        limit: 5,
        template: ['<p>{{name}} {{#email}}<span class="email">- {{email}}{{/email}}</p>',
                   '<p class="details">{{status}}</p>',
                   '<p class="details">{{department}}</p>',
                   '<button data-id={{comp_id}} type="button" class="copy-button">Copy ID to clipboard</button>'
                  ].join(''),
        engine: Hogan
    });

    $(document).on('click', '.copy-button', function(e){
        chrome.runtime.sendMessage({ type: "selection", comp_id: $(this).data('id') });
        $.get( "http://uvasear.ch/update?id=" + datum.comp_id, function(data) {});
    });
});

(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','https://ssl.google-analytics.com/ga.js','ga');

ga('create', 'UA-46216711-1', 'extension.com');
ga('send', 'pageview');