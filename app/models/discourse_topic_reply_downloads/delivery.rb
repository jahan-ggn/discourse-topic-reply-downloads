# frozen_string_literal: true

module DiscourseTopicReplyDownloads
  class Delivery < ActiveRecord::Base
    self.table_name = "discourse_topic_reply_downloads_deliveries"

    belongs_to :topic
    belongs_to :user
    belongs_to :trigger_post, class_name: "Post"
    belongs_to :message_post, class_name: "Post", optional: true

    def sent?
      sent_at.present?
    end
  end
end
