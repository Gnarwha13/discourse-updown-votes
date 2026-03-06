# frozen_string_literal: true

class UpdownVote < ActiveRecord::Base
  belongs_to :user

  DIRECTIONS = %w[up down].freeze

  validates :user_id,      presence: true
  validates :votable_type, presence: true, inclusion: { in: %w[Topic Post] }
  validates :votable_id,   presence: true
  validates :direction,    presence: true, inclusion: { in: DIRECTIONS }
  validates :user_id, uniqueness: { scope: [:votable_type, :votable_id] }

  # Net score for a topic (sum of +1 for up, -1 for down)
  def self.score_for_topic(topic_id)
    where(votable_type: "Topic", votable_id: topic_id)
      .sum("CASE WHEN direction = 'up' THEN 1 ELSE -1 END")
  end

  # Net score for a post
  def self.score_for_post(post_id)
    where(votable_type: "Post", votable_id: post_id)
      .sum("CASE WHEN direction = 'up' THEN 1 ELSE -1 END")
  end

  # Total score received by a user across all their topics and posts
  def self.score_for_user(user_id)
    topic_ids = Topic.where(user_id: user_id).pluck(:id)
    post_ids  = Post.where(user_id: user_id).pluck(:id)

    topic_score = where(votable_type: "Topic", votable_id: topic_ids)
                    .sum("CASE WHEN direction = 'up' THEN 1 ELSE -1 END")
    post_score  = where(votable_type: "Post", votable_id: post_ids)
                    .sum("CASE WHEN direction = 'up' THEN 1 ELSE -1 END")

    topic_score + post_score
  end
end
