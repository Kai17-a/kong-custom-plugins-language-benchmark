import { BASE_URL, options, callAndCheck  } from "./config.js";

export { options };

export default function () {
  callAndCheck(`${BASE_URL}/js/anything`);
}
