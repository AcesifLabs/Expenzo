export function getDatabaseSslConfig(
  databaseUrl?: string,
  databaseSsl?: string,
): false | { rejectUnauthorized: false } {
  if (databaseSsl === 'true') {
    return { rejectUnauthorized: false };
  }

  if (databaseSsl === 'false') {
    return false;
  }

  if (!databaseUrl) {
    return false;
  }

  try {
    const { hostname } = new URL(databaseUrl);
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return false;
    }
  } catch {
    return false;
  }

  return { rejectUnauthorized: false };
}
