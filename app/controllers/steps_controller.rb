require 'open-uri'
require 'json'

class StepsController < ApplicationController

  def update
    @sloopy = Sloopy.find(params[:sloopy_id])
    raise
    new_step = eval(@sloopy.questions.last.ai_answer.split(/:\s*\n\n(?<data>{.*})/)[1])
    old_city_sentence = @sloopy.questions.last.ai_answer.split(/:\s*\n\n(?<data>{.*})/)[0]

    all_cities = @sloopy.steps.pluck(:city_stop)
    all_cities.each do |city|
      # found the regex
      # old_city = all_cities.match(city)
    end

    modified_step = @sloppy.steps.find_by(old_city: old_city)
    modified_step.update!(
      city: new_step[:city],
      transport: new_step[:transport],
      cost: new_step[:cost],
      duration: new_step[:duration],
      longitude: Geocoder.search(new_step[:city_stop]).first.coordinates[0],
      latitude: Geocoder.search(new_step[:city_stop]).first.coordinates[1],
      city_stop: new_step[:city_stop],
      activities: new_step[:activities].map do |activity|
        Activity.new(name: activity[:name], address: activity[:address])
      end
    )

    # find next step
    # if @sloopy.find(modified_step.id + 1)
    #   @sloopy.find(modified_step.id + 1).gsub(old_city, modified_step.city_stop)




    # var options = {
    #   types: ['(cities)'],
    #   componentRestrictions: {country: 'us'}
    # };

  end
end
