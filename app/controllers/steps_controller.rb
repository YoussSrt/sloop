require 'open-uri'
require 'json'

class StepsController < ApplicationController
  # def update
  #   @sloopy = Sloopy.find(params[:sloopy_id])
  #   new_step = eval(@sloopy.questions.last.ai_answer.split(/:\s*\n\n(?<data>{.*})/)[1])
  #   old_city_sentence = @sloopy.questions.last.ai_answer.split(/:\s*\n\n(?<data>{.*})/)[0]

  #   all_cities = @sloopy.steps.pluck(:city_stop) # Récupère les noms des villes
  #   regex = /remplacer\s+([A-Z][a-zéèêëàâäîïôöùûüç]+)/

  #   all_cities.each do |city|
  #     if city.match(regex)
  #       old_city = city.match(regex)
  #     end
  #   end

  #   modified_step = @sloppy.steps.find_by(old_city: old_city)
  #   modified_step.update!(
  #     city: new_step[:city],
  #     transport: new_step[:transport],
  #     cost: new_step[:cost],
  #     duration: new_step[:duration],
  #     longitude: Geocoder.search(new_step[:city_stop]).first.coordinates[0],
  #     latitude: Geocoder.search(new_step[:city_stop]).first.coordinates[1],
  #     city_stop: new_step[:city_stop],
  #     activities: new_step[:activities].map do |activity|
  #       Activity.new(name: activity[:name], address: activity[:address])
  #     end
  #     )
  #     raise

  #     # find next step
  #     # if @sloopy.find(modified_step.id + 1)
  #   #   @sloopy.find(modified_step.id + 1).gsub(old_city, modified_step.city_stop)




  #   # var options = {
  #   #   types: ['(cities)'],
  #   #   componentRestrictions: {country: 'us'}
  #   # };

  # end
end
