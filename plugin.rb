# frozen_string_literal: true

# name: discourse-topic-reply-downloads
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 2.7.0

enabled_site_setting :discourse_topic_reply_downloads_enabled

module ::DiscourseTopicReplyDownloads
  PLUGIN_NAME = "discourse-topic-reply-downloads"
end

require_relative "lib/discourse_topic_reply_downloads/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
