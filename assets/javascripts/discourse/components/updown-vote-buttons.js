import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { service } from "@ember/service";

export default class UpdownVoteButtons extends Component {
  @service currentUser;
  @service siteSettings;

  @tracked score = this.args.score ?? 0;
  @tracked userVote = this.args.userVote ?? null;
  @tracked loading = false;

  get canVote() {
    return !!this.currentUser;
  }

  get upActive() {
    return this.userVote === "up";
  }

  get downActive() {
    return this.userVote === "down";
  }

  get scoreClass() {
    if (this.score > 0) return "positive";
    if (this.score < 0) return "negative";
    return "neutral";
  }

  @action
  stopPropagation(e) {
    e.stopPropagation();
    e.preventDefault();
  }

  @action
  async vote(direction) {
    if (!this.canVote || this.loading) return;
    this.loading = true;

    try {
      const result = await ajax("/updown-votes", {
        type: "POST",
        data: {
          votable_type: this.args.votableType,
          votable_id:   this.args.votableId,
          direction,
        },
      });
      this.score    = result.score;
      this.userVote = result.direction;
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.loading = false;
    }
  }
}
