chrome.runtime.onMessage.addListener(
  function(request, sender, sendResponse) {
        chrome.tabs.create({ url: "https://www.google.com/search?q=" + request.person + " uva"});
        sendResponse({ });
});