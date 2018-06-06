$.ajax({
    url: "/api/categories",
    type: "GET",
    contentType: "application/json; charset=utf-8"
}).then(function (response) {
    var dataToReturn = [];
    for (var i = 0; i < response.length; i++) {
        var tagToTransform = response[i];
        var newTag = {
            id: tagToTransform["title"],
            text: tagToTransform["title"]
        };

        dataToReturn.push(newTag);
    }

    $("#placeCategories").select2({
        language: {
            noResults: function () {
                return "Нет категорий"
            }
        },
        placeholder: "Выберите категории для места",
        tags: true,
        tokenSeparators: [','],
        data: dataToReturn
    });
});
