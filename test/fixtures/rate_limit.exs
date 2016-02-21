#
# HTTPoison.get!("https://api.github.com/rate_limit")
#

%HTTPoison.Response{body: "{\"resources\":{\"core\":{\"limit\":5000,\"remaining\":5000,\"reset\":1456026238},\"search\":{\"limit\":30,\"remaining\":30,\"reset\":1456022698}},\"rate\":{\"limit\":5000,\"remaining\":5000,\"reset\":1456026238}}",
 headers: [{"Server", "GitHub.com"}, {"Date", "Sun, 21 Feb 2016 02:43:58 GMT"},
  {"Content-Type", "application/json; charset=utf-8"},
  {"Content-Length", "187"}, {"Status", "200 OK"},
  {"X-RateLimit-Limit", "5000"}, {"X-RateLimit-Remaining", "5000"},
  {"X-RateLimit-Reset", "1456026238"}, {"Cache-Control", "no-cache"},
  {"X-GitHub-Media-Type", "github.v3; format=json"},
  {"Access-Control-Allow-Credentials", "true"},
  {"Access-Control-Expose-Headers",
   "ETag, Link, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval"},
  {"Access-Control-Allow-Origin", "*"},
  {"Content-Security-Policy", "default-src 'none'"},
  {"Strict-Transport-Security", "max-age=31536000; includeSubdomains; preload"},
  {"X-Content-Type-Options", "nosniff"}, {"X-Frame-Options", "deny"},
  {"X-XSS-Protection", "1; mode=block"}, {"Vary", "Accept-Encoding"},
  {"X-Served-By", "2c18a09f3ac5e4dd1e004af7c5a94769"},
  {"X-GitHub-Request-Id", "322EDDE3:14592:EA28A06:56C9246D"}], status_code: 200}
