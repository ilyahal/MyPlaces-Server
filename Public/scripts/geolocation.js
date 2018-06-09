$("#getGeolocationButton").click(function () {
    if ("geolocation" in navigator) {
        navigator.geolocation.getCurrentPosition(function (position) {
            $('#geolocationLatitude').val(position.coords.latitude);
            $('#geolocationLongitude').val(position.coords.longitude);
        });
    } else {
        console.log("Browser doesn't support geolocation!");
    }
});
