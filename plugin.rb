# frozen_string_literal: true

# name: discourse-topic-reply-downloads
# about: Sends a private message with download links when a member replies to a configured topic.
# version: 0.0.1
# authors: Jahan Gagan
# url: https://github.com/jahan-ggn/discourse-topic-reply-downloads

enabled_site_setting :discourse_topic_reply_downloads_enabled

module ::DiscourseTopicReplyDownloads
  PLUGIN_NAME = "discourse-topic-reply-downloads"
end

require_relative "lib/discourse_topic_reply_downloads/engine"

after_initialize do
  on(:post_created) do |post, options, _user|
    next if options&.dig(:import_mode)
    next unless post.post_number > 1
    next unless post.post_type == Post.types[:regular]
    next unless post.user_id.to_i > 0
    next unless post.topic&.archetype == Archetype.default

    next unless DiscourseTopicReplyDownloads::Rules.for_topic(post.topic_id)

    post_id = post.id

    ActiveRecord.after_all_transactions_commit do
      Jobs.enqueue(:topic_reply_downloads_deliver, post_id: post_id)
    end
  rescue DiscourseTopicReplyDownloads::Rules::InvalidConfiguration => error
    Discourse.warn_exception(
      error,
      message: "[discourse-topic-reply-downloads] Invalid configuration for topic #{post.topic_id}",
    )
  end
end
