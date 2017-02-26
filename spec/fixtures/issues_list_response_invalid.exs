#
# HTTPoison.get!("https://api.github.com/repos/foo/bar/issues")
#

%HTTPoison.Response{body: "{\"message\":\"Not Found\",\"documentation_url\":\"https://developer.github.com/v3\"}",
 headers: [{"Server", "GitHub.com"}, {"Date", "Wed, 17 Feb 2016 05:44:43 GMT"},
  {"Content-Type", "application/json; charset=utf-8"}, {"Content-Length", "77"},
  {"Status", "404 Not Found"}, {"X-RateLimit-Limit", "60"},
  {"X-RateLimit-Remaining", "59"}, {"X-RateLimit-Reset", "1455691483"},
  {"X-GitHub-Media-Type", "github.v3; format=json"},
  {"Access-Control-Allow-Credentials", "true"},
  {"Access-Control-Expose-Headers",
   "ETag, Link, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval"},
  {"Access-Control-Allow-Origin", "*"},
  {"Content-Security-Policy", "default-src 'none'"},
  {"Strict-Transport-Security", "max-age=31536000; includeSubdomains; preload"},
  {"X-Content-Type-Options", "nosniff"}, {"X-Frame-Options", "deny"},
  {"X-XSS-Protection", "1; mode=block"},
  {"X-GitHub-Request-Id", "322EDDE3:A4E9:FB74022:56C408CB"}], status_code: 404}
