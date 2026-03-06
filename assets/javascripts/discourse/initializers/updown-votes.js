import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "updown-votes",
  initialize() {
    withPluginApi("0.8.31", (api) => {
      // Nothing needed here – connectors and components handle UI
    });
  },
};
