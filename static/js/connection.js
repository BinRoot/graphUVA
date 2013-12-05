$(document).ready(function(){
    var opts = {
        lines:7,
        length:30,
        width:10,
        radius:19,
        corners:0.8,
        rotate:23,
        trail:74,
        speed:0.9,
        direction:1
    };
    var target = document.getElementById('load');
    var spinner = new Spinner(opts).spin(target);

    $("#load").hide();
    $(".results").hide();

    $(".search-page").keyup(function (e) {
        if (e.keyCode == 13) {
            $(".search-page").prop('disabled', true);
            $(".results").hide();
            $("#load").show();
            $.get("http://uvasear.ch/similarity?url=" + $(".search-page").val(), function(data) {
                $(".results").empty();
                $(".results").append('<tr><th>Name</th></tr>');

                for (var i = 0; i < data.length; i++){
                    $(".results").append('<tr><td>' + data[i] +  '</td></tr>');
                }

                $("#load").hide();
                $(".results").show();
                $(".search-page").prop('disabled', false);
            });
        }
    });
});
