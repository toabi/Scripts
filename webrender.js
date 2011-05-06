#!/usr/bin/env phantomjs

/* webrender 0.1
 * 07.05.2011 - Tobias Birmili
 *
 * Uses Phantom.js to render a given website as a png.
 * Requirements: <http://www.phantomjs.org/>
 */

if (phantom.state.length === 0) {
    if (phantom.args.length === 0) {
        console.log('Usage: renderWebsite.js <URL>');
        phantom.exit();
    } else {
        var address = phantom.args[0];
        phantom.state = 'loading';
        console.log('Loading ' + address);
        phantom.open(address);
    }
} else {
    if (phantom.loadStatus === 'success') {
       var filename = 'Screenshot_' + document.title + '.png';
       console.log('saved to ' + filename);
       phantom.render(filename);
    } else {
        console.log('Error: failed to load the address!');
    }
    phantom.exit();
}