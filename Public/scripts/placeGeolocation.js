$("#placeGetLocationButton").click(function () {
    if ("geolocation" in navigator) {
        navigator.geolocation.getCurrentPosition(function (position) {
            $('#placeLatitude').val(position.coords.latitude);
            $('#placeLongitude').val(position.coords.longitude);
        });
    } else {
        console.log("Browser doesn't support geolocation!");
    }
});
