console.log('Starting Short URL Service...');

// URL database (in production, this would be server-side)
const urlDatabase = new Map();

// Initialize from prebuilt seed (generated from urls.csv at build/start)
(function seedFromPrebuilt() {
  if (Array.isArray(window.URL_SEED)) {
    for (const item of window.URL_SEED) {
      if (!item || !item.short || !item.long) continue;
      urlDatabase.set(item.short, { url: item.long, tags: item.tags || 'Imported', created: new Date().toISOString() });
    }
    console.log(`Seed loaded: ${urlDatabase.size} mappings`);
  } else {
    console.warn('No URL_SEED found; only newly-created links will work this session.');
  }
})();

// Client-side routing: if path is a shortcode, show redirect and navigate
(function handleRouting() {
  const path = window.location.pathname;
  if (
    path !== '/' &&
    path !== '/index.html' &&
    !path.includes('.html') &&
    !path.includes('.css') &&
    !path.includes('.js')
  ) {
    // Support optional trailing slash
    const shortCode = path.replace(/^\//, '').replace(/\/$/, '');
    const urlData = urlDatabase.get(shortCode);

    if (urlData) {
      document.body.innerHTML = `
        <div class="redirect-page">
          <div class="redirect-container">
            <div class="redirect-icon">🔗</div>
            <h2 class="redirect-title">Redirecting...</h2>
            <p class="redirect-subtitle">You are being redirected from <strong>eled.org/${shortCode}</strong></p>
            <div class="destination-box"><strong>Destination:</strong> ${maskUrl(urlData.url)}</div>
            <div class="progress-container">
              <div class="progress-bar">
                <div class="progress-fill"></div>
              </div>
            </div>
            <p class="redirect-footer">
              If you are not redirected automatically,
              <a href="${urlData.url}">click here</a>
            </p>
          </div>
        </div>
      `;
      setTimeout(() => (window.location.href = urlData.url), 2500);
      return;
    } else {
      document.body.innerHTML = `
        <div class="redirect-page error-page">
          <div class="redirect-container">
            <div class="error-icon">❌</div>
            <h2 class="error-title">URL Not Found</h2>
            <p class="redirect-subtitle">The short URL <strong>"eled.org/${shortCode}"</strong> does not exist or has expired.</p>
          </div>
        </div>
      `;
      return;
    }
  }
})();

function maskUrl(url) {
  try {
    const urlObj = new URL(url);
    const domain = urlObj.hostname;
    const path = urlObj.pathname.length > 30 ? urlObj.pathname.substring(0, 30) + '...' : urlObj.pathname;
    return `${domain}${path}`;
  } catch {
    return url.length > 60 ? url.substring(0, 60) + '...' : url;
  }
}

function shortenUrl() {
  console.log('shortenUrl called');
  const longUrlInput = document.getElementById('longUrl');
  const loadingDiv = document.getElementById('loading');
  const errorDiv = document.getElementById('error');
  const resultDiv = document.getElementById('result');
  const shortUrlDiv = document.getElementById('shortUrl');

  const longUrl = longUrlInput.value.trim();

  // Reset UI
  loadingDiv.style.display = 'none';
  errorDiv.style.display = 'none';
  resultDiv.style.display = 'none';

  if (!longUrl) {
    showError('Please enter a URL');
    return;
  }

  // Add protocol if missing
  let processedUrl = longUrl;
  if (!longUrl.startsWith('http://') && !longUrl.startsWith('https://')) {
    processedUrl = 'https://' + longUrl;
  }

  // Validate URL
  try {
    new URL(processedUrl);
  } catch (e) {
    showError('Please enter a valid URL');
    return;
  }

  // Show loading
  loadingDiv.style.display = 'block';

  // Simulate processing
  setTimeout(() => {
    const shortCode = Math.random().toString(36).substring(2, 8);
    const shortUrl = `eled.org/${shortCode}`;

    // Store the new URL
    urlDatabase.set(shortCode, {
      url: processedUrl,
      tags: 'Custom',
      created: new Date().toISOString(),
    });

    shortUrlDiv.textContent = shortUrl;
    loadingDiv.style.display = 'none';
    resultDiv.style.display = 'block';

    // Clear input
    longUrlInput.value = '';

    // Update the list
    updateUrlList();
    updateStats();

    console.log('Generated short URL:', shortUrl);
  }, 600);
}

function showError(message) {
  const errorDiv = document.getElementById('error');
  errorDiv.textContent = message;
  errorDiv.style.display = 'block';

  setTimeout(() => {
    errorDiv.style.display = 'none';
  }, 5000);
}

function copyToClipboard() {
  const shortUrlDiv = document.getElementById('shortUrl');
  const shortUrl = 'https://' + shortUrlDiv.textContent;

  navigator.clipboard
    .writeText(shortUrl)
    .then(() => {
      const copyBtn = event.target;
      const originalText = copyBtn.textContent;
      copyBtn.textContent = 'Copied! ✓';
      copyBtn.style.background = '#45a049';

      setTimeout(() => {
        copyBtn.textContent = originalText;
        copyBtn.style.background = '#4caf50';
      }, 2000);
    })
    .catch(() => {
      // Fallback
      const textArea = document.createElement('textarea');
      textArea.value = shortUrl;
      document.body.appendChild(textArea);
      textArea.select();
      document.execCommand('copy');
      document.body.removeChild(textArea);

      const copyBtn = event.target;
      const originalText = copyBtn.textContent;
      copyBtn.textContent = 'Copied! ✓';
      copyBtn.style.background = '#45a049';

      setTimeout(() => {
        copyBtn.textContent = originalText;
        copyBtn.style.background = '#4caf50';
      }, 2000);
    });
}

function updateUrlList() {
  const urlList = document.getElementById('urlList');
  if (!urlList) return;

  urlList.innerHTML = '';
  let count = 0;

  for (const [shortCode, urlData] of urlDatabase) {
    if (count >= 5) break;

    const urlItem = document.createElement('div');
    urlItem.className = 'url-item';
    urlItem.onclick = () => copyShortUrl(shortCode);
    urlItem.innerHTML = `
      <strong>eled.org/${shortCode}</strong>
      <small style="color: #666; display: block; margin-top: 5px;">${maskUrl(urlData.url)}</small>
      <small style="color: #999; font-size: 0.8em;">${urlData.tags} • ${formatDate(urlData.created)}</small>
    `;
    urlList.appendChild(urlItem);
    count++;
  }
}

function copyShortUrl(shortCode) {
  const shortUrl = `https://eled.org/${shortCode}`;
  navigator.clipboard
    .writeText(shortUrl)
    .then(() => {
      showNotification('Short URL copied to clipboard!');
    })
    .catch(() => {
      showNotification('Short URL copied: ' + shortUrl);
    });
}

function showNotification(message) {
  const notification = document.createElement('div');
  notification.style.cssText = `
    position: fixed; top: 20px; right: 20px; background: #4caf50; color: white;
    padding: 15px 20px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
    z-index: 1000; animation: slideInRight 0.3s ease-out;
  `;
  notification.textContent = message;
  document.body.appendChild(notification);

  setTimeout(() => {
    notification.style.animation = 'slideOutRight 0.3s ease-in forwards';
    setTimeout(() => document.body.removeChild(notification), 300);
  }, 3000);
}

function formatDate(dateString) {
  const date = new Date(dateString);
  const now = new Date();
  const diffTime = Math.abs(now - date);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

  if (diffDays === 1) return 'Today';
  if (diffDays <= 7) return `${diffDays} days ago`;
  return date.toLocaleDateString();
}

function updateStats() {
  const totalUrlsElement = document.getElementById('totalUrls');
  const totalClicksElement = document.getElementById('totalClicks');

  if (totalUrlsElement) {
    totalUrlsElement.textContent = urlDatabase.size;
  }

  if (totalClicksElement) {
    totalClicksElement.textContent = Math.floor(Math.random() * 1000) + 500; // Simulate clicks
  }
}

// Handle Enter key and initialize

document.addEventListener('DOMContentLoaded', function () {
  console.log('DOM loaded');
  const longUrlInput = document.getElementById('longUrl');
  if (longUrlInput) {
    longUrlInput.addEventListener('keypress', function (e) {
      if (e.key === 'Enter') {
        shortenUrl();
      }
    });
    longUrlInput.focus();
  }

  // Initialize the page
  updateUrlList();
  updateStats();
});

console.log('Script loaded successfully');
