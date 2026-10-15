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
  # Code which should run after Rails has finished booting
end
