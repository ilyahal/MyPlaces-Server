$(document).ready(function() {
    var latitude = $("#map").attr("latitude");
    var longitude = $("#map").attr("longitude");

    var myMap;
    ymaps.ready(init);
    function init () {
        myMap = new ymaps.Map("map", {
            center: [latitude, longitude],
            zoom: 15
        });

        myMap.geoObjects.add(new ymaps.Placemark([latitude, longitude]));
    }
});
