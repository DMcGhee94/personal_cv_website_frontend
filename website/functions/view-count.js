const functionUrl = "https://fnapp7smkosjl3tpco.azurewebsites.net/api/viewcount";

const triggerViewCount = async (method) => {
    return fetch(functionUrl, {
            method: method
        })
        .then(response => response.text())
        .then(text => text)
        .catch(error => console.error(error));
};

const onLoadViewCount = async (method) => {
    const viewCount = await triggerViewCount(method);
    console.log(`View Count: ${viewCount}`);

    const viewCountElement = document.getElementById('viewcount');
    var viewCountContent = viewCountElement.innerText;
    viewCountElement.innerText = `Total Views: ${viewCount}`;
};