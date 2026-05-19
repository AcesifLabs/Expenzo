// Force IPv4 DNS resolution for pg driver
// Only active when FORCE_IPV4=true in env (useful in dev networks where IPv6 is unreachable)
// On IPv6-capable VPS, leave FORCE_IPV4 unset so Node uses default resolution
// Monkey-patch must run BEFORE any pg/TypeORM imports

if (process.env.FORCE_IPV4 === 'true') {
  const dns = require('dns');
  const origLookup = dns.lookup;
  (dns.lookup as any) = (
    hostname: string,
    options: any,
    callback?: any,
  ) => {
    if (typeof options === 'function') {
      callback = options;
      options = {};
    }
    return origLookup(hostname, { ...options, family: 4 }, callback);
  };
}
