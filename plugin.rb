# frozen_string_literal: true

# name: discourse-updown-votes
# about: Adds up/downvoting to topics and posts with score tracking
# version: 1.0.0
# authors: Custom
# url: https://github.com/your-org/discourse-updown-votes

enabled_site_setting :updown_votes_enabled

register_asset "stylesheets/updown-votes.scss"

after_initialize do
  # Models
  require_relative "app/models/updown_vote"

  # Controllers
  require_relative "app/controllers/updown_votes_controller"

  # Add routes
  Discourse::Application.routes.append do
    post   "/updown-votes"        => "updown_votes#create"
    delete "/updown-votes"        => "updown_votes#destroy"
    get    "/updown-votes/scores" => "updown_votes#scores"
  end

  # Extend TopicList serializer to include vote data
  add_to_serializer(:topic_list_item, :updown_vote_score) do
    UpdownVote.score_for_topic(object.id)
  end

  add_to_serializer(:topic_list_item, :user_updown_vote) do
    return nil unless scope.current_user
    vote = UpdownVote.find_by(votable_type: "Topic", votable_id: object.id, user_id: scope.current_user.id)
    vote&.direction
  end

  # Extend Post serializer
  add_to_serializer(:post, :updown_vote_score) do
    UpdownVote.score_for_post(object.id)
  end

  add_to_serializer(:post, :user_updown_vote) do
    return nil unless scope.current_user
    vote = UpdownVote.find_by(votable_type: "Post", votable_id: object.id, user_id: scope.current_user.id)
    vote&.direction
  end
