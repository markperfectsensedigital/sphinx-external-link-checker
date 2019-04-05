# Spinx External Link Checker

This Perl script recurses through a Sphinx output directory `_build/html` and checks that links in `href` attributes are legitimate. We wrote this script because the built-in Sphinx feature `-b linkcheck` checks every single link in a Sphinx project, resulting in too many false warnings about broken links.

The script sends a `HEAD` request and collects the response. Then script then sends the results to a file `/tmp/url_list.csv`.

The most common response to this script's request is `200 OK`. However, you may get different responses:

* `404 Not Found` -- Some servers, such as GitHub, return 404 if you are not logged in.
* `405 Method Not Allowed`, `503 Service Not Available` -- Some servers, such as Twilio, do not accept the `HEAD` request.

In these cases, check the URL in a browser.