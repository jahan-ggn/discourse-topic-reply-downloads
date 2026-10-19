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

# == Schema Information
#
# Table name: discourse_topic_reply_downloads_deliveries
#
#  id              :bigint           not null, primary key
#  sent_at         :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  message_post_id :integer
#  topic_id        :integer          not null
#  trigger_post_id :integer          not null
#  user_id         :integer          not null
#
# Indexes
#
#  idx_topic_reply_downloads_topic_user  (topic_id,user_id) UNIQUE
#
