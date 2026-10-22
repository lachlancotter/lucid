# Browser specs

Run the title regression tests with:

```sh
bundle install
bundle exec rspec spec/browser/title_spec.rb
```

These tests use headless Chrome through Capybara and Selenium. Install Chrome;
Selenium manages ChromeDriver automatically (the first run may need network access).
WEBrick serves the test app on a local, automatically allocated port.

The tests exercise real Lucid link requests and HTMX swaps, checking the browser's
document title and DOM identity to rule out a full page reload. They cover nested
title composition, SVG title preservation, and escaped titles with no DOM changes.

HTMX 2.0.4 is served from `spec/fixtures/htmx-2.0.4.min.js` so the tests do not
depend on a CDN. This is the unmodified distribution from
https://unpkg.com/htmx.org@2.0.4/dist/htmx.min.js, with the same SHA-384 digest as
`HTMX::LIB`. Its license is in `spec/fixtures/htmx-LICENSE`.
