$(function() {
    var getListings = require('./firebase.js')['getListings'];
    var wNumb = require('wNumb');
    var auth = require('./firebase.js')["auth"];

    auth.onAuthStateChanged(function(user) {
        if (user) {
            $("#find-favorite-logged-in").css('display', 'block');
            $("#find-favorite-logged-out").css('display', 'none');
        } else {
            $("#find-favorite-logged-in").css('display', 'none');
            $("#find-favorite-logged-out").css('display', 'block');
        }
    });    

    var slider = $("#search-slider");
    if (slider.length > 0) {
        
        noUiSlider.create(slider[0], {
            start: [1, 500],
            connect: true,
            step: 1,
            tooltips: true,
            format: wNumb({
                decimals: 0,
                thousand: ',',
                prefix: '$',
            }),
            range: {
                'min': 1,
                'max': 3000
            }
        });
    }



    var newListing = function(currentItems) {
        var imageSwitcher = true;
        $("#find-content").empty();
        for (var item in currentItems) {
            
            var currentItem = currentItems[item];
            var currentImage = imageSwitcher ? 
                "http://www.ikea.com/PIAimages/0122106_PE278491_S5.JPG" : 
                "./iphone-sample.jpg";
            imageSwitcher = !imageSwitcher;
            console.log("test");
            $("#find-content").append(
                $("<div></div>").addClass("col l4 m4 s12").append(
                    $("<div></div>").addClass("card find-result hoverable").append(
                        $("<div></div>").addClass("find-result-favorite").append(
                            $("<img/>").addClass("find-result-favorite-image").attr({
                                src: "../media/ic_heart.png",
                                alt: "heart"
                            })
                        )
                    ).append(
                        $("<div></div>").addClass("find-result-price").text(
                            "$" + currentItem["price"])).append(
                        $("<div></div>").addClass("card-image waves-effect waves-block waves-light").append(
                            $("<img/>").addClass("activator").attr({
                                src: currentImage
                            })
                        )
                    ).append(
                        $("<div></div>").addClass("card-content").append(
                            $("<span></span>").addClass("card-title activator grey-text text-darken-4").text(
                                    currentItem["title"]
                            ).append(
                                $("<i></i>").addClass("material-icons right").text("more_vert")
                            )
                        ).append(
                            $("<p></p>").append(
                                $("<a></a>").attr({
                                    href: "#"
                                }).text(
                                    "view item"
                                )
                            )
                        )
                    ).append(
                        $("<div></div>").addClass("card-reveal").append(
                            $("<span></span>").addClass("card-title grey-text text-darken-4").text(
                                "Description"
                            ).append(
                                $("<i></i>").addClass("material-icons right").text(
                                    "close"
                                )
                            ).append(
                                $("<p></p>").text(
                                    currentItem["description"]
                                )
                            )
                        )
                    )
                )
            );
        };
    };

    $('input.autocomplete').autocomplete({
        data: {
            "Apple": null,
            "Microsoft": null,
            "Google": 'http://placehold.it/250x250'
        }
    });

    $("#find-search-button").click(function () {
        query = "key=";
        keywords = $("#item-post-title").val();
        keywords = $("#item-post-title").val();
        
        query += keywords === "" ? "none" : "" + keywords;
        location.hash = query;
        getListings(newListing);
    });


    // favorite icon highlight/changes
    $('body').on('mouseenter', '.find-result-favorite-image', function() {
        $(this).attr('src', '../media/ic_heart_hover.png');
        $(this).css('opacity', '0.7');
    }).on('mouseout', '.find-result-favorite-image', function() {
        if (!this.favorited) {
            $(this).attr('src', '../media/ic_heart.png');
            $(this).css('opacity', '0.3');
        }
    }).on('click', '.find-result-favorite-image', function() {
        this.favorited = this.favorited || false;
        if (!this.favorited) {
            $(this).attr('src', '../media/ic_heart_hover.png');
        } else {
            $(this).attr('src', '../media/ic_heart.png');
        }
        this.favorited = !this.favorited;
    });

});