// ==UserScript==
// @name         Replace image with custom image
// @namespace    http://tampermonkey-test-site.com/
// @version      1.0
// @description  Replaces the image with class "title" with a custom image
// @match https://searxng.nicfab.eu/searxng/*
// @match https://search.notashelf.dev/*

// @grant        GM_xmlhttpRequest
// @grant        GM_addElement

// ==/UserScript==

(function () {
  "use strict";
  var element = document.querySelector("#main_index > div > div");
  if (!element) return;
  GM_xmlhttpRequest({
    method: "GET",
    url: "https://raw.githubusercontent.com/Arjun31415/dotfiles/fcaeb4f241b6a4b9634d10eeb45b9cfa61a4a3c2/misc/.config/misc/SearXNG.svg", // Replace the URL with your own custom image URL
    responseType: "blob",
    onload: function (response) {
      var urlCreator = window.URL || window.webkitURL;
      var imageUrl = urlCreator.createObjectURL(response.response);
      element.style.backgroundImage = "none";
      element.style.backgroundSize = "cover"; // Add any additional CSS properties for the new background image
      element.style.backgroundRepeat = "no-repeat";
      element.style.backgroundPosition = "center center";
      element.style.backgroundColor = "transparent";
      GM_addElement(element, "img", {
        src: imageUrl,
        // can use mask in the future so that users can style the image themselves
        /* style:
          "   mask-image: linear-gradient(to bottom, rgba(0,0,0,0) 0%,rgba(0,0,0,0.65) 100%);-webkit-mask-image: linear-gradient(to bottom, rgba(0,0,0,0) 0%,rgba(0,0,0,0.65) 100%);", */
      });
    },
  });
})();
