class GenerateSloopyJob < ApplicationJob
  queue_as :default

  def perform(sloopy, formatted_preferences, current_index)
    puts "Generating Sloopy..."
    OpenAiService.new(sloopy, formatted_preferences, current_index).call
  end
end
