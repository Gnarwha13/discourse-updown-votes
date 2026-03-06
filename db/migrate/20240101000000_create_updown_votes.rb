# frozen_string_literal: true

class CreateUpdownVotes < ActiveRecord::Migration[7.0]
  def change
    create_table :updown_votes do |t|
      t.integer  :user_id,       null: false
      t.string   :votable_type,  null: false   # "Topic" or "Post"
      t.integer  :votable_id,    null: false
      t.string   :direction,     null: false   # "up" or "down"
      t.timestamps
    end

    add_index :updown_votes, [:user_id, :votable_type, :votable_id], unique: true
    add_index :updown_votes, [:votable_type, :votable_id]
    add_index :updown_votes, :user_id
  end
end
