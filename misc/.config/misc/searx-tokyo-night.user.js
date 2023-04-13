// ==UserScript==
// @name         Replace image with custom image
// @namespace    http://tampermonkey-test-site.com/
// @version      1.0
// @description  Replaces the image with class "title" with a custom image
// @match https://searxng.nicfab.eu/searxng/*
// @grant        none
// ==/UserScript==

(function () {
  "use strict";
  var element = document.querySelector("#main_index > div > div");
  element.style.background = "none";
  element.style.backgroundImage =
    "url('https://searxng.nicfab.eu/searxng/image_proxy?url=https%3A%2F%2Fstockimages.org%2Fwp-content%2Fuploads%2F2020%2F10%2Fbigstock-Photography-Concept-African-A-381364544.jpg&h=bf142ed8641b33d1e889ca67d5d80c5955465a539ff228136e3860de30c162a5')"; // Remove the background-image property
  element.style.backgroundSize = "cover"; // Add any additional CSS properties for the new background image
  element.style.backgroundRepeat = "no-repeat";
  element.style.backgroundPosition = "center center";
  element.style.backgroundColor = "#f2f2f2";
})();
