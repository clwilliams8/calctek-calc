<!DOCTYPE html>
<html>
<head><title>Signing in...</title></head>
<body>
<script>
  window.location.href = @json($frontendUrl) + '/auth/callback?token=' + encodeURIComponent(@json($token));
</script>
<p>Signing in&hellip; Redirecting.</p>
</body>
</html>
