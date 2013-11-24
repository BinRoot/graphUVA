chrome.runtime.onMessage.addListener(function(request, sender, sendResponse){
    var newURL = "http://stackoverflow.com/";
    chrome.tabs.create({ url: "https://www.google.com/search?q=" + request.person + " uva"});
});