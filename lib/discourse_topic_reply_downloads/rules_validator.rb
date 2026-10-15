# frozen_string_literal: true

module DiscourseTopicReplyDownloads
  class RulesValidator < ::ObjectsSettingValidator
    def valid_value?(value)
      return false unless super

      rules = Rules.parse(value)

      enabled_rules = rules.select { |rule| rule.fetch("enabled", true) == true }

      duplicate_topic_ids =
        enabled_rules
          .group_by { |rule| rule["topic_id"] }
          .select { |_topic_id, topic_rules| topic_rules.size > 1 }
          .keys
          .sort

      if duplicate_topic_ids.any?
        @error =
          I18n.t(
            "discourse_topic_reply_downloads.errors.duplicate_topics",
            topic_ids: duplicate_topic_ids.join(", "),
          )

        return false
      end

      rules.each { |rule| MessageBuilder.new(rule).build }

      true
    rescue Rules::InvalidConfiguration => error
      @error =
        I18n.t(
          "discourse_topic_reply_downloads.errors.invalid_configuration",
          reason: error.message,
        )

      false
    end
  end
end
