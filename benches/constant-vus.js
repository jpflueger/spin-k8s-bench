import http from 'k6/http';
import { check, group } from 'k6';

const FUNC_BASE_URL = __ENV.FUNC_BASE_URL || 'http://20.232.216.30';

const scenarioOptions = {
    executor: 'constant-vus',
    vus: 10,
    duration: '30s',
    exec: 'get_hello',
};

export const options = {
    scenarios: {
        spin_js: Object.assign({
            env: {
                FUNC_URL: `${FUNC_BASE_URL}/spin/js/hello`,
            },
            tags: {
                FUNC_LANG: 'js',
                FUNC_RUNTIME: 'spin',
            },
        }, scenarioOptions),
        spin_py: Object.assign({
            env: {
                FUNC_URL: `${FUNC_BASE_URL}/spin/py/hello`,
            },
            tags: {
                FUNC_LANG: 'py',
                FUNC_RUNTIME: 'spin',
            },
        }, scenarioOptions),
    }
};

export function get_hello() {
    const res = http.get(__ENV.FUNC_URL);
    check(res, { 'status was 200': (r) => r.status == 200 });
}
