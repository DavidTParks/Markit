$(function() {
    var getListings = require('./firebase.js')['getListings'];

    var slider = $("#search-slider");
    if (slider.length > 0) {
        
        noUiSlider.create(slider[0], {
            start: [0, 300],
            connect: true,
            step: 1,
            tooltips: true,
            range: {
                'min': 0,
                'max': 1500
            }
        });
    }

    var newListing = function(currentItems) {
        var imageSwitcher = true;
        for (var item in currentItems) {
            
            var currentItem = currentItems[item];
            var currentImage = imageSwitcher ? 
                "http://www.ikea.com/PIAimages/0122106_PE278491_S5.JPG" : 
                "./iphone-sample.jpg"
            imageSwitcher = !imageSwitcher;

            $("#find-content").append(
                $("<div></div>").addClass("col l4 m4 s12").append(
                    $("<div></div>").addClass("card find-result").append(
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
                                    currentItem["item"]
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

    getListings(newListing);

});