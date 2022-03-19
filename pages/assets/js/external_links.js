// Contain every link in an array.
var links = document.querySelectorAll('a');

// For every link,
for (var i = 0; i < links.length; i++) {

  // if the link's hostname is different from own hostname,
  // i.e. if the link is external,
  if (links[i].hostname != window.location.hostname) {

    // change the target and rel value as the following.
    links[i].target = '_blank';
    links[i].rel = 'noopener';

  }
}
