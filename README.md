# Short URL Service for eled.org

A professional URL shortening service with domain masking, designed specifically for eled.org.

## 🌟 Features

- ✅ **URL Shortening**: Convert long URLs into short eled.org links
- ✅ **Domain Masking**: Shows eled.org in browser during redirects
- ✅ **CSV Import**: Automatically loads existing URLs from CSV file
- ✅ **Click Tracking**: Monitor usage statistics for each short URL
- ✅ **Responsive Design**: Works perfectly on all devices
- ✅ **Copy to Clipboard**: One-click copying of short URLs
- ✅ **Local Storage**: Persists data across browser sessions
- ✅ **Progressive Redirect**: 3-second branded redirect page
- ✅ **404 Handling**: Professional error pages for invalid URLs
- ✅ **Security Headers**: Built-in security protections

## 🚀 Quick Start

1. Install dependencies (one time):
   - PowerShell: `npm install`
2. Start local server (rewrites deep links to index.html):
   - PowerShell: `npm start`
3. Test in browser:
   - Home: `http://localhost:8000/`
   - Redirect: `http://localhost:8000/4526`

Alternative simple servers (no deep-link rewrites):
- `npm run start:py` (Python http.server)
- `npm run start:php` (PHP built-in server)

Note: For deep links like `/4526`, prefer `npm start` which uses a SPA-friendly static server.

## 📁 File Structure

```
ShortURL/
├── index.html          # Main interface
├── script.js           # Core functionality and routing
├── styles.css          # Responsive styling
├── urls.csv            # Initial URL data from your scraper
├── .htaccess           # Apache configuration
├── 4526.html           # Minimal no-JS fallback for a key code
└── README.md           # This file
```

## 🔧 How It Works

### URL Shortening Process
1. User enters a long URL
2. System generates unique short code
3. Mapping stored in memory (client-side demo) and shown in UI
4. Short URL created: `eled.org/shortcode`

### Redirect Process
1. User visits `eled.org/shortcode`
2. Client app shows branded redirect page
3. Progress bar displays short countdown
4. User forwarded to destination URL

### Data Loading
- Seeds include codes like `4526` so deep links work immediately
- Additional mappings are loaded from `urls.csv` on page load

## 🧪 Test Scenarios

- Home loads without errors
- Create a short link and copy to clipboard
- Navigate directly to `/4526` and confirm redirect
- Invalid path (e.g., `/nope`) shows friendly 404

## 🛠 Production Notes

- Ensure Apache `mod_rewrite` is enabled; `.htaccess` routes all non-file paths to `index.html`
- Security and caching headers are configured in `.htaccess`
- Optional: add server-side 301s for critical codes if desired
- Keep `urls.csv` accessible (allowed by `.htaccess`) for CSV-driven imports

## 🚀 Deployment

1. Upload all files to the web root or subfolder for eled.org
2. Ensure Apache mod_rewrite is enabled
3. Verify `.htaccess` is honored (no server-level overrides)
4. Test critical codes that use server-side 301s (e.g., `/4526`)
5. Test client-side redirects for non-critical codes
6. Optionally add more 301 rules for high-traffic links

## ✅ Post-deploy verification

- `https://eled.org/` loads the app UI
- `https://eled.org/4526` returns 301 directly to destination
- `https://eled.org/6349` returns 301 directly to destination
- Random non-file path routes to `index.html` and shows 404 UI

## 🧹 Cleanup Checklist (pre-production)

- [ ] Remove `index-working.html` if not needed
- [x] Remove temporary test pages (`simple.html`, `test.html`)
- [ ] Verify all required short codes exist (via `urls.csv` or seeds)

## 🧹 Cleanup

- [x] Remove temporary test pages
- [ ] Remove `index-working.html` when comfortable
- [ ] Commit and tag a release

## 📈 Analytics Integration

To add Google Analytics or other tracking:

1. Add tracking code to `index.html`
2. Track events in `script.js`:
   ```javascript
   gtag('event', 'url_created', { event_category: 'engagement', event_label: shortCode });
   ```

## 🔧 Server Requirements

- Web Server: Apache 2.4+ (with mod_rewrite)
- HTTPS: SSL certificate recommended
- Storage: Minimal

## 🐛 Troubleshooting

- If `/4526` 404s locally, use `npm start` (rewrites enabled)
- If redirects don’t fire, confirm `<script src="script.js" defer></script>` is present
- If CSV doesn’t load, ensure `urls.csv` is readable and not cached

## 📞 Support

For technical support or customization requests, refer to the documentation or contact your development team.

## 📄 License

This Short URL service is proprietary software developed for eled.org. All rights reserved.
