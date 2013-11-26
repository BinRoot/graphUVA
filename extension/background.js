chrome.runtime.onMessage.addListener(
  function(request, sender, sendResponse) {
        alert("message recieved");
        chrome.tabs.create({ url: "https://www.google.com/search?q=" + request.person + " uva"});
        window.close();
        sendResponse({ });
});