import http from "k6/http";
import { check } from "k6";

export const BASE_URL = "http://localhost:8000/api";

export const options = {
  scenarios: {
    constant_request_rate: {
      executor: "constant-arrival-rate",
      // rate: 100
      // rate: 300
      rate: 500,
      timeUnit: "1s",
      duration: "60s",
      preAllocatedVUs: 300,
      maxVUs: 10000,
    },
  },
};

export function callAndCheck(url) {
  const res = http.get(url);
  check(res, {
    "status is 200": (r) => r.status === 200,
  }) || console.log(`Failed request: ${res.status} ${res.body}`);
  return res;
}
