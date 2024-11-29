namespace :geocode do
  desc "Update coordinates for all existing Sloopies"
  task update_coordinates: :environment do
    puts "Updating coordinates for all Sloopies..."
    Sloopy.find_each do |sloopy|
      puts "Processing Sloopy #{sloopy.id}: #{sloopy.origin} -> #{sloopy.destination}"
      
      # Force update coordinates
      origin_result = Geocoder.search(sloopy.origin).first
      if origin_result
        sloopy.update_columns(
          origin_latitude: origin_result.latitude,
          origin_longitude: origin_result.longitude
        )
      end

      destination_result = Geocoder.search(sloopy.destination).first
      if destination_result
        sloopy.update_columns(
          destination_latitude: destination_result.latitude,
          destination_longitude: destination_result.longitude
        )
      end
    end
    puts "Done!"
  end
end
