$(function () {
    $('.parallax').parallax();
    var getRecentItemsInHub = require('./firebase.js')['getRecentItemsInHub'];
    var itemImagesRef = require('./firebase.js')["itemImagesRef"];
    var auth = require('./firebase.js')["auth"];
    var getImage = require('./firebase.js')["getImage"];
    var populateSuggestionsInHub = require('./firebase.js')['populateSuggestionsInHub'];



    var mostRecentItems = $('#hub-most-recent');
    var showMostRecentItems = function(items) {
        var imagePaths = []
        var str = $('#hub-most-recent').text();
        var compiled = _.template(str);

        $('#hub-recent-holder').empty();
        $('#hub-recent-holder').prepend(compiled({items: items}));


        for (var item in items) {
            imagePaths.push(items[item]['id']);
        }

        for (var i = 0; i < imagePaths.length; i += 1) {
            (function (x) {
                getImage(imagePaths[x] + '/imageOne', function(url) {
                    tagToAdd = ".hub-recent img:eq(" + x  + " )";
                    $(tagToAdd).attr({src: url});
                });
            })(i);
        }
    };

    var showSuggestions = function(suggestions) {
        Promise.resolve(suggestions).then(function(itemList) {

            console.log(itemList);
            for (let i = 0; i < itemList.length; i += 1) {
            }
        });
    }

    auth.onAuthStateChanged(function(user) {
        if (user && $(mostRecentItems).length > 0) {
            getRecentItemsInHub('Loyola Marymount University', showMostRecentItems);
            showSuggestions(populateSuggestionsInHub('Loyola Marymount University', auth.currentUser.uid));
        } else if (!user && $(mostRecentItems).length > 0) {
            window.location.href = "../index.html";

        }
    });    
    

});