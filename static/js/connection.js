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
            setTimeout(function(){
                $("#load").hide();
                $(".results").show();
                $(".search-page").prop('disabled', false);
            },3000);
        }
    });
});
