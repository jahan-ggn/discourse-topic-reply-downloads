# frozen_string_literal: true

module ::Jobs
  class TopicReplyDownloadsDeliver < ::Jobs::Base
    def execute(args)
      DiscourseTopicReplyDownloads::Deliverer.call(post_id: args.fetch(:post_id))
    rescue DiscourseTopicReplyDownloads::Rules::InvalidConfiguration => error
      Discourse.warn_exception(
        error,
        message:
          "[discourse-topic-reply-downloads] Invalid configuration for post #{args[:post_id]}",
      )
    end
  end
end
