# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Fixe la graine aléatoire pour garantir la reproductibilité
srand(1234)

puts "La seed est effacée, les anciennes données sont supprimées..."

User.destroy_all
Sloopy.destroy_all

puts "La nouvelle seed se crée..."

european_cities = [
  "Paris", "Berlin", "Madrid", "Rome", "Vienna",
  "Amsterdam", "Brussels", "Copenhagen", "Dublin", "Lisbon"
]

puts "Création des utilisateurs..."
users = User.create!([
  {
    email: "user1@example.com",
    password: "azerty",
    password_confirmation: "azerty",
    nickname: "Traveler1",
    first_name: "Alice",
    last_name: "Smith"
  },
  {
    email: "user2@example.com",
    password: "azerty",
    password_confirmation: "azerty",
    nickname: "Explorer2",
    first_name: "Bob",
    last_name: "Johnson"
  },
  {
    email: "user3@example.com",
    password: "azerty",
    password_confirmation: "azerty",
    nickname: "Wanderer3",
    first_name: "Charlie",
    last_name: "Brown"
  }
])

puts "Utilisateurs créés avec succès."

puts "Création des sloopies..."
3.times do |i|
  # Durée fixe pour rendre le seed déterministe
  duration = [3,4,5,6,7].sample

  # Budget par jour (entre 10 et 300), multiplié par la durée
  budget = rand(200..1000) * duration

  # Statut : 20% "done", le reste aléatoire
  if i < 2 # 20% des sloopies
    status = "false"
    departure_date = Date.today - rand(30..365) # Départ il y a max 1 an
    return_date = departure_date + duration
  else
    status = %w[delate save in progress].sample
    departure_date = Date.today + rand(0..365) # Dans les 12 prochains mois
    return_date = departure_date + duration
  end

  # Assurez-vous que l'origine et la destination sont différentes
  origin = european_cities.sample
  destination = (european_cities - [origin]).sample

  Sloopy.create!(
    origin: origin,
    destination: destination,
    departure_date: departure_date,
    return_date: return_date,
    budget: budget,
    duration: duration,
    status: status,
    user_id: users[i % users.size].id # Répartit les trajets entre les utilisateurs
  )
end

puts "Sloopies créés avec succès."
puts "Nouvelle seed créé avec succès."

puts "Création des preferences"

# favorite_activities
[
  "Outdoor",
  "Sports",
  "Creative",
  "Cultural",
  "Relaxation",
  "Social",
  "Party"
].each do |preference| 
  Preference.create(
    category: "favorite_activities",
    choice: preference
  )
end

# ideal_travel_pace
[
  "Very active",
  "Active",
  "Balanced",
  "Relaxed",
  "Flexible",
  "Lazy"
].each do |preference| 
  Preference.create(
    category: "ideal_travel_pace",
    choice: preference
  )
end

# exciting_experiences
[
  "Nature",
  "City exploration",
  "Local events",
  "Food & drinks",
  "Shopping",
  "Learning"
].each do |preference| 
  Preference.create(
    category: "exciting_experiences",
    choice: preference
  )
end

# traveling_with
 [
  "Solo",
  "Couple",
  "Family",
  "Friends",
  "Group"
].each do |preference| 
  Preference.create(
    category: "traveling_with",
    choice: preference
  )
end

# preferred_vibe
 [
  "Adventure",
  "Chill",
  "Luxury",
  "Off-the-beaten-path",
  "Minimal",
  "Social",
  "Lonely"
].each do |preference| 
  Preference.create(
    category: "preferred_vibe",
    choice: preference
  )
end

# main_travel_goal 
 [
  "Adventure",
  "Relaxation",
  "Discovering cultures",
  "Trying new foods",
  "Connecting with people"
].each do |preference| 
  Preference.create(
    category: "main_travel_goal",
    choice: preference
  )
end
