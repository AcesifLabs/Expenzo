




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
