class ExampleJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.logger.info "Example Job!"
    puts "Example Job!"
    SocialEntry.create(text: "Example Job!", user: User.last)
  end
end
