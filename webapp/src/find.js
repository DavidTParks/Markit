'use strict'
$(function() {
    var getListings = require('./firebase.js')['getListings'];
    var getFavorites = require('./firebase.js')['getFavorites'];
    var wNumb = require('wNumb');
    var auth = require('./firebase.js')["auth"];
    var itemImagesRef = require('./firebase.js')["itemImagesRef"];
    var addFavoriteToProfile = require('./firebase.js')['addFavoriteToProfile'];
    var removeFavorite = require('./firebase.js')['removeFavorite'];
    var getFavoriteObjects = require('./firebase.js')['getFavoriteObjects'];
    var getImage = require('./firebase.js')['getImage'];


    var favoriteTemplate = $('#favorite-template');
    var showFavoritesInSidebar = function(favorites) {
        
        var str = $('#favorite-template').text();
        var compiled = _.template(str);

        $('#favorite-holder').empty();
        $('#favorite-holder').append(compiled({favorites: favorites}));

        for (var i = 0; i < favorites.length; i += 1) {
            (function (x) {
                getImage(favorites[x]['id'] + '/imageOne', function(url) {
                    let tagToAdd = ".favorite-image img:eq(" + x  + " )";
                    $(tagToAdd).attr({src: url});
                });
            })(i);
        }
    };



    auth.onAuthStateChanged(function(user) {
        if (user && $(favoriteTemplate).length > 0) {
            getFavoriteObjects(showFavoritesInSidebar);
            $("#find-favorite-logged-in").css('display', 'block');
            $("#find-favorite-logged-out").css('display', 'none');


            // favorite icon highlight/changes
            $('body').on('mouseenter', '.find-result-favorite-image', function() {
                $(this).attr('src', '../media/ic_heart_hover.png');
                $(this).css('opacity', 1);
            }).on('mouseout', '.find-result-favorite-image', function() {
                if (!this.favorited) {
                    $(this).attr('src', '../media/ic_heart.png');
                    $(this).css('opacity', '0.3');
                }
            }).on('click', '.find-result-favorite-image', function() {
                this.favorited = this.favorited || false;
                if (!this.favorited) {
                    $(this).attr('src', '../media/ic_heart_hover.png');
                    addFavoriteToProfile(auth.currentUser.uid, $(this).attr('uid'));
                    getFavoriteObjects(showFavoritesInSidebar);

                } else {
                    $(this).attr('src', '../media/ic_heart.png');
                    removeFavorite($(this).attr('uid'));
                    getFavoriteObjects(showFavoritesInSidebar);
                }
                this.favorited = !this.favorited;
            });            
        } else {
            $("#find-favorite-logged-in").css('display', 'none');
            $("#find-favorite-logged-out").css('display', 'block');
        }
    });    

    var slider = $("#search-slider");
    if (slider.length > 0) {
        // Add dropdown hub selector
        $('select').material_select();
        // add slider
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

        slider[0].noUiSlider.get()
    }

    var showFavoritesInSearches = function(currentFavorites) {
        $('.find-result-favorite-image').each(function() {
            var  currentImageID = $(this).attr('uid');
            if(currentFavorites && currentFavorites[currentImageID]) {
                $(this).attr('src', '../media/ic_heart_hover.png');
                $(this).css('opacity', 1);
                this.favorited = true;

            }

        });
    };

    var newSearch = function(currentItems, keywords = [], tags = [], hubs = [], priceRange = []) {
        Promise.resolve(currentItems).then(function(itemList) {
            var str = $('#find-results-template').text();
            var compiled = _.template(str);
            var imagePaths = [];
            var filteredItemList = {};        
            
            for (var item in itemList) {
                var currentItem = itemList[item];
                var itemID = currentItem['id'];
                var itemDescription = currentItem['description'].toLowerCase();
                var itemTitle = currentItem['title'].toLowerCase();
                var itemPrice = parseInt(currentItem['price'])
                imagePaths.push(itemID);


                if (hubs.length > 0 && !hubs.some(hub => currentItem['hubs'].includes(hub))) {
                    continue;
                }

                if (tags.length > 0 && !tags.some(tag => currentItem['tags'].includes(tag))) {
                    continue;
                }

                if (keywords.length > 0 && (!keywords.some(key => itemTitle.includes(key)) &&
                    !keywords.some(key => itemDescription.includes(key)))) {
                        continue
                }

                if (itemPrice < priceRange[0] || itemPrice > priceRange[1]) {
                    continue;
                }
                    
                //200
                //203-204

                filteredItemList[itemID] = currentItem
            }

            $("#find-content-presearch").hide()
            $('#find-results-holder').empty();
            $('#find-results-holder').append(compiled({filteredItemList: filteredItemList}));


            getFavorites(showFavoritesInSearches);

            for (var i = 0; i < imagePaths.length; i += 1) {
                (function (x) {
                    getImage(imagePaths[x] + '/imageOne', function(url) {
                        $("#" + imagePaths[x]).attr({src: url});
                    });
                })(i);
            }            
        });
    };

    $('input.autocomplete').autocomplete({
        data: {
            "Apple": null,
            "Microsoft": null,
            "Google": 'http://placehold.it/250x250'
        }
    });

    $("#find-search-button").click(function () {
        var query = "key=";
        var keywords = $("#find-keywords").val().toLowerCase().trim().split(/\s+/);    
        var hubs = $("#find-hubs").val();
        var tags = [];
        var priceRange = slider[0].noUiSlider.get();

        for (let i = 0; i < priceRange.length; i += 1) {
            priceRange[i] = parseInt(priceRange[i].replace(/[^0-9.]/g, ''));
        }
        
        query += keywords === "" ? "none" : "" + keywords;
        location.hash = query;

        newSearch(getListings(), keywords, tags, hubs, priceRange);
    });




});