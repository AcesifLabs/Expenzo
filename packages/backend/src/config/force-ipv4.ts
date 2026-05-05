// Force IPv4 DNS resolution for pg driver
// IPv6 unreachable in some networks, Node tries it first and times out
// Monkey-patch must run BEFORE any pg/TypeORM imports

import * as dns from 'dns';

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
