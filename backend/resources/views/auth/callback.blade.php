<!DOCTYPE html>
<html>
<head><title>Signing in...</title></head>
<body>
<script>
  if (window.opener) {
    window.opener.postMessage(
      { type: 'oauth-callback', token: @json($token) },
      @json($frontendUrl)
    );
    window.close();
  } else {
    window.location.href = @json($frontendUrl) + '/auth/callback?token=' + @json($token);
  }
</script>
<p>Signing in&hellip; This window should close automatically.</p>
</body>
</html>
