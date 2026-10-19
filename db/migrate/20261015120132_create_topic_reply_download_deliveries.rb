# frozen_string_literal: true

class CreateTopicReplyDownloadDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :discourse_topic_reply_downloads_deliveries do |table|
      table.integer :topic_id, null: false
      table.integer :user_id, null: false
      table.integer :trigger_post_id, null: false
      table.integer :message_post_id
      table.datetime :sent_at

      table.timestamps null: false
    end

    add_index :discourse_topic_reply_downloads_deliveries,
              %i[topic_id user_id],
              unique: true,
              name: "idx_topic_reply_downloads_topic_user"
  end
end
