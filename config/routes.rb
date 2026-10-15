# frozen_string_literal: true

DiscourseTopicReplyDownloads::Engine.routes.draw do
  get "/examples" => "examples#index"
  # define routes here
end

Discourse::Application.routes.draw { mount ::DiscourseTopicReplyDownloads::Engine, at: "discourse-topic-reply-downloads" }
