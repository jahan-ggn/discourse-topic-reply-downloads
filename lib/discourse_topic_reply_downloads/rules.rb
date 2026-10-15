# frozen_string_literal: true

module DiscourseTopicReplyDownloads
  class Rules
    class InvalidConfiguration < StandardError
    end

    def self.all
      parse(SiteSetting.discourse_topic_reply_downloads_rules)
    end

    def self.parse(value)
      rules = value.is_a?(String) ? JSON.parse(value) : value

      unless rules.is_a?(Array) && rules.all? { |rule| rule.is_a?(Hash) }
        raise InvalidConfiguration, "Download rules must be an array of objects"
      end

      rules
    rescue JSON::ParserError
      raise InvalidConfiguration, "Download rules contain invalid JSON"
    end

    def self.for_topic(topic_id)
      matching_rules =
        all.select { |rule| rule.fetch("enabled", true) == true && rule["topic_id"] == topic_id }

      if matching_rules.size > 1
        raise InvalidConfiguration,
              "Multiple enabled download rules are configured for topic #{topic_id}"
      end

      matching_rules.first
    end
  end
end
