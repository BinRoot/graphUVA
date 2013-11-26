chrome.runtime.onMessage.addListener(
    function(request, sender, sendResponse) {
        if(request.type === "selection"){
            chrome.tabs.create({ url: "https://www.google.com/search?q=" + request.person + " uva"});
            window.close();
            sendResponse({ });
        } else {
            window.close();
            sendResponse({ });
        }
});