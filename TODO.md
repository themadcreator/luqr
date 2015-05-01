i would like this repo to have the following properties.

all PRs require test verification.
npm installing this module does not pull down resources other that hte library (no gh-pages)
people making PRs can easily see how it would change the pages.


(all PRs go to master)
master -> release (npm publish from here)
       -> gh-pages (contains site only)

single commands to :
 1. release new version, and publish site
