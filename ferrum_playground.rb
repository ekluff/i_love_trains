# NOTE: the code in this file DOES NOT WORK. I wrote this knowing that it was not the core part of the task,
# and having asked and received a small amount of clarification for the intructions, that building a web scraper
# was not expected at all. 

# I am including it anyways for two reasons: 1) I would find it interesting if a candidate included it, and
# 2) I have not written a web scraper in several years and wanted to experiement with current tools.
# Before this, I had never used the Ferrum gem. It was fun to try something new and I did learn some things
# about web crawling and programatically interacting with Chrome dev tools.

# Below are some notes about my approach.

# Fundamentally, what we need to do is this: construct a web request that is indistinguishable 
# from that sent by the website's own SPA, send it, and gather the response for parsing.

# There are two basic approaches we could use to build a request:
# - retrieve all the necessary information from the website (cookies, headers, tokens, etc.) and use it to manually reconstruct a request
# - let the website build its own request as normal, catch it before sending, only modify the parts we need, and let it continue

# In principle, the second approach might be simpler, so I wanted to try this as a proof of concept. In practice, code like this
# is VERY BRITTLE and usually better suited to automated tests.

# The web request needs to have all the various parts that make it legitimate to the backend.
# This might include:
# - appropriate header values. Not every backend checks headers in the same way. Here are some that are usually important
#   - accept, accept-encoding, content-length, origin, referrer, cors policies, cache busting, authorization
#   - trainline does not appear to use an authorization header
#   - primary security of trainline appears to be cookie based
#   - user-agent header often used to detect suspicious activity
#     - after running my script several times I encountered unusual errors -- possibly soft blocking. This may have been user-agent based. 
#       I might have been able to overcome this using the puppeteer-extra-stealth plugin, which also works with ferrum.
#       Shoutout to https://railsnotes.xyz/blog/ferrum-stealth-browsing#adding-the-puppeteer-extra-stealth-plugin
# - appropriate cookie values. The main security of api/journey-search appears to be cookie based. I note various relevant cookies:
#   - datadome. This appears to be a captcha/puzzle-based anti-bot tool. I encountered this several times but did not automate it.
#   - dpiCookie. I was not able to conclusively identify what this is, but it appears to be important.
#   - consent cookie. Probably not used for security but it is possible to check anything for suspicious patterns.
# - session based security. This is (usually? always?) handled via cookies, but am listing it separately because it is
#   by itself, a whole area of web security. It is usually necessary to have the appropriate session id and all the various
#   token values matching that session. Much of this is handled intransparently by Rails and various gems (e.g. Devise).

# The basic flow of the trainline site is:
# - search for origin location (GET /api/locations-search/v2)
# - search for destination location (GET /api/locations-search/v2)
# - search for trips (POST /api/journey-search)

# Trainline publishes an official csv of all their internal station data, including IDs, at https://github.com/trainline-eu/stations.
# From this it would be possible to search for a location locally and infer the location code (e.g. "urn:trainline:generic:loc:7686"),
# obviating the need to call /api/locations-search/v2 before calling /api/journey-search.
# However, since the instructions specify that the inputs are *exactly* what we need,
# I guess that means our user will input the trainline internal code for us and we don't have to look it up anyways.

require 'ferrum'

url = 'https://thetrainline.com/api/journey-search'

# TODO grab inputs from the user and search in the stations CSV data
from_id = 7686 # Munich region parent station
to_id = 4916 # Paris region parent station
departure_at = DateTime.now

# this requires chrome/chromium to be installed on the host machine
b = Ferrum::Browser.new(
  incognito: true, # new session every time
  headless: false, # pops open a browser window so you can follow the fun; normally this would be true
  browser_options: {
    'auto-open-devtools-for-tabs': true,
    'window-size': '4000,1080' # just make it wide enough so that we don't get the collapsed view
  }
)

b.network.intercept
b.on(:request) do |request|
  if request.match?(/api\/journey-search/)
    puts request.body
    original_body = JSON.parse(request.body)
    
    # TODO modify the body with new origin, destination, departure_at
    # values to modify are: 
    # body['origin']
    # body['destination']
    # body['transitDefitions'][0]['origin']
    # body['transitDefitions'][0]['destination']
    # body['transitDefitions'][0]['journeyDate']['time']

    new_body = original_body
    headers = request.headers

    # TODO set the appropriate new content-length of the headers
    # headers["Content-Length"] = new_body.bytesize

    # according to https://github.com/rubycdp/ferrum/commit/5271866198dad526ca898344459f1a5afa2efafb it is indeed possible to modify requests before they are sent
    # the attributes that can be modified are those supported by DevTools and include postData, i.e. the body of the request
    # see https://chromedevtools.github.io/devtools-protocol/tot/Fetch/#method-continueRequest for other available attrs
    request.continue(
      headers: headers,
      # postData should be the base64 encoded string of the request body
      postData: new_body
    )
  else
    request.continue
  end
end

b.go_to('https://thetrainline.com')

# it takes a bit for the consent banner to load for the first time
# an optimization to skip this step would be to check the status of consent in the cookies; it is visible there
sleep 0.5

# close consent banner, not sure if this matters
consent = b.at_css('button.onetrust-close-btn-handler')
consent.click if consent.focusable?
sleep 0.4
b.at_css('input#jsf-origin-input').click
sleep 0.1
b.at_css('li#jsf-origin-item-0').click
sleep 0.1
# This fails if the page starts in collapsed-view mode
# in expanded mode, the site opens the destination search menu immediately. In collapsed mode you have to click the destination field first.
# so if you open the browser with dev tools, it starts in collapsed mode and this fails.
# so we open the browser 4000px wide (see above)
b.at_css('li#jsf-destination-item-0').click
sleep 0.1
b.at_css('input#bookingPromo').click
sleep 0.2
# this button doesn't work unless you focus on it first for some reason (maybe so my bot doesn't work)
b.at_css('button[data-testid="jsf-submit"]').focus.click