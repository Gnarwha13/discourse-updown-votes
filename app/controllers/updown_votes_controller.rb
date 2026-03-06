# frozen_string_literal: true

class UpdownVotesController < ApplicationController
  requires_plugin "discourse-updown-votes"
  before_action :ensure_logged_in
  before_action :ensure_votes_enabled

  def create
    type      = params.require(:votable_type)
    votable_id = params.require(:votable_id).to_i
    direction  = params.require(:direction)

    raise Discourse::InvalidParameters unless %w[Topic Post].include?(type)
    raise Discourse::InvalidParameters unless %w[up down].include?(direction)

    trust_required = SiteSetting.updown_votes_require_trust_level
    unless current_user.trust_level >= trust_required
      return render_json_error(
        I18n.t("updown_votes.trust_level_required", level: trust_required),
        status: 403
      )
    end

    vote = UpdownVote.find_or_initialize_by(
      user_id:      current_user.id,
      votable_type: type,
      votable_id:   votable_id
    )

    # Toggle: if same direction, remove the vote
    if vote.persisted? && vote.direction == direction
      vote.destroy!
      new_direction = nil
    else
      vote.direction = direction
      vote.save!
      new_direction = direction
    end

    score = type == "Topic" ? UpdownVote.score_for_topic(votable_id) : UpdownVote.score_for_post(votable_id)

    render json: { direction: new_direction, score: score }
  end

  def destroy
    type      = params.require(:votable_type)
    votable_id = params.require(:votable_id).to_i

    vote = UpdownVote.find_by(
      user_id:      current_user.id,
      votable_type: type,
      votable_id:   votable_id
    )

    vote&.destroy!
    score = type == "Topic" ? UpdownVote.score_for_topic(votable_id) : UpdownVote.score_for_post(votable_id)

    render json: { direction: nil, score: score }
  end

  def scores
    user_id = params[:user_id] || current_user.id
    render json: { score: UpdownVote.score_for_user(user_id) }
  end

  private

  def ensure_votes_enabled
    raise Discourse::NotFound unless SiteSetting.updown_votes_enabled
  end
end
