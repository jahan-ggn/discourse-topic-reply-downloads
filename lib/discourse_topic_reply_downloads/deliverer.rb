# frozen_string_literal: true

module DiscourseTopicReplyDownloads
  class Deliverer
    def self.call(post_id:)
      return unless SiteSetting.discourse_topic_reply_downloads_enabled

      post = Post.includes(:topic, :user).find_by(id: post_id)
      return unless eligible_post?(post)

      recipient = post.user
      return unless recipient.active? && !recipient.staged? && !recipient.suspended?
      return unless recipient.guardian.can_see?(post.topic)

      rule = Rules.for_topic(post.topic_id)
      return unless rule

      sender_username =
        SiteSetting.discourse_topic_reply_downloads_sender.presence ||
          Discourse.system_user.username
      sender = User.find_by_username(sender_username)

      unless sender&.active? && !sender.staged? && !sender.suspended?
        raise Rules::InvalidConfiguration,
              "The configured PM sender '#{sender_username}' is missing, inactive, staged, or suspended"
      end

      message = MessageBuilder.new(rule).build

      delivery =
        Delivery.create_or_find_by!(topic_id: post.topic_id, user_id: recipient.id) do |record|
          record.trigger_post_id = post.id
        end

      creator = nil

      delivery.with_lock do
        unless delivery.sent?
          creator =
            PostCreator.new(
              sender,
              message.merge(
                archetype: Archetype.private_message,
                target_usernames: recipient.username,
                skip_validations: true,
                skip_jobs: true,
              ),
            )

          message_post = creator.create!

          delivery.update!(
            trigger_post_id: post.id,
            message_post_id: message_post.id,
            sent_at: Time.current,
          )
        end
      end

      creator&.enqueue_jobs

      delivery
    end

    def self.eligible_post?(post)
      post.present? && post.post_number > 1 && post.post_type == Post.types[:regular] &&
        post.deleted_at.nil? && !post.hidden? && post.user_id.to_i > 0 && post.user.present? &&
        post.topic.present? && post.topic.deleted_at.nil? &&
        post.topic.archetype == Archetype.default
    end

    private_class_method :eligible_post?
  end
end
