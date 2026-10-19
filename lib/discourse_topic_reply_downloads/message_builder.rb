# frozen_string_literal: true

require "uri"

module DiscourseTopicReplyDownloads
  class MessageBuilder
    ATTACHMENT_PLACEHOLDER = /\{\{attachment:([^{}\r\n]+)\}\}/

    def initialize(rule)
      @rule = rule
    end

    def build
      links = attachment_links
      referenced_identifiers = []

      body =
        @rule
          .fetch("pm_body")
          .gsub('\n', "\n")
          .gsub(ATTACHMENT_PLACEHOLDER) do
            identifier = Regexp.last_match(1).strip

            unless links.key?(identifier)
              raise Rules::InvalidConfiguration,
                    "The PM message references an unknown attachment identifier: #{identifier}"
            end

            referenced_identifiers << identifier
            links.fetch(identifier)
          end

      if body.include?("{{attachment:")
        raise Rules::InvalidConfiguration, "An attachment placeholder is incomplete or invalid"
      end

      remaining_links =
        links.reject { |identifier, _link| referenced_identifiers.include?(identifier) }.values

      { title: @rule.fetch("pm_subject"), raw: ([body.strip] + remaining_links).join("\n\n") }
    end

    private

    def attachment_links
      attachments = @rule["attachments"] || []

      unless attachments.is_a?(Array)
        raise Rules::InvalidConfiguration, "Attachments must be a list"
      end

      attachments.each_with_object({}) do |attachment, links|
        identifier = attachment["identifier"]

        unless identifier.is_a?(String) && identifier.match?(/\A[a-z][a-z0-9_]{0,63}\z/)
          raise Rules::InvalidConfiguration,
                "Each attachment needs an identifier of up to 64 characters, starting with a lowercase letter and containing only lowercase letters, numbers, and underscores"
        end

        if links.key?(identifier)
          raise Rules::InvalidConfiguration,
                "Attachment identifiers must be unique within a rule: #{identifier}"
        end

        name = attachment.fetch("name").strip
        url = attachment.fetch("url").strip

        if name.empty? || name.match?(/[\r\n]/)
          raise Rules::InvalidConfiguration,
                "Attachment names must be non-empty and cannot contain line breaks"
        end

        validate_url!(url)

        links[identifier] = attachment_markdown(name, url)
      end
    end

    def attachment_markdown(name, url)
      if upload = local_upload(url)
        return UploadMarkdown.new(upload).to_markdown(display_name: name)
      end

      label = name.gsub(/[\\`*_\[\]<>]/) { |character| "\\#{character}" }
      "[#{label}](<#{url}>)"
    end

    def local_upload(url)
      uri = URI.parse(url)
      site_uri = URI.parse(Discourse.base_url)

      unless uri.scheme == site_uri.scheme && uri.host == site_uri.host && uri.port == site_uri.port
        return
      end

      if sha1 = Upload.sha1_from_short_path(uri.path)
        Upload.find_by(sha1: sha1)
      else
        Upload.get_from_url(url)
      end
    end

    def validate_url!(url)
      uri = URI.parse(url)

      unless %w[http https].include?(uri.scheme) && uri.host.present? && uri.userinfo.nil? &&
               !url.match?(/[\s<>\x00-\x1f\x7f]/)
        raise Rules::InvalidConfiguration,
              "Attachment URLs must be absolute HTTP or HTTPS links without spaces or credentials"
      end
    rescue URI::InvalidURIError
      raise Rules::InvalidConfiguration, "An attachment URL is invalid"
    end
  end
end
