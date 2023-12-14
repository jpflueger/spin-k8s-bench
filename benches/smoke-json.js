import http from 'k6/http';
import { check, sleep } from 'k6';
import { textSummary } from 'https://jslib.k6.io/k6-summary/0.0.4/index.js';

export default function() {
  const res = http.get(__ENV.FUNC_URL, {
    tags: {
      runtime: __ENV.FUNC_RT,
      language: __ENV.FUNC_LANG,
    }
  });
  check(res, { 'status was 200': (r) => r.status == 200 });
  sleep(1);
}

export function handleSummary(data) {
  const filename = `${__ENV.OUT_DIR}/summary-${__ENV.FUNC_RT}-${__ENV.FUNC_LANG}.json`;
  return {
    'stdout': textSummary(data, { indent: ' ', enableColors: true }),
    [filename]: JSON.stringify(data), //the default data object
  };
}
