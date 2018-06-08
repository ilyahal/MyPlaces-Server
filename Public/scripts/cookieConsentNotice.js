function cookiesConfirmed() {
    $('#cookieFooter').hide();

    var date = new Date();
    date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000)); // 1 год

    var expires = "expires="+ date.toUTCString();
    document.cookie = "cookies-accepted=true;" + expires;
}
