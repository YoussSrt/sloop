srand(1234)

puts "La seed est effacée, les anciennes données sont supprimées..."

# Supprimer les préférences utilisateurs d'abord
UserPreference.delete_all
Preference.delete_all

# Supprimer les utilisateurs
User.destroy_all

# Supprimer les sloopies (si vous avez besoin de supprimer aussi les sloopies)
Sloopy.destroy_all
Step.destroy_all
Review.destroy_all

puts "La nouvelle seed se crée..."

european_cities = [
  "Paris", "Berlin", "Madrid", "Rome", "Vienna",
  "Amsterdam", "Brussels", "Copenhagen", "Dublin", "Lisbon",
  "Athens", "Prague", "Stockholm", "Budapest", "Oslo"
]

puts "Création des utilisateurs..."
users = User.create!([
  {
    email: "user1@example.com",
    password: "azerty",
    password_confirmation: "azerty",
    nickname: "Explorer1",
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
    nickname: "Explorer3",
    first_name: "Charlie",
    last_name: "Brown"
  },
  {
    email: "user4@example.com",
    password: "azerty",
    password_confirmation: "azerty",
    nickname: "Explorer4",
    first_name: "David",
    last_name: "Williams"
  }
])

users.each do |user|
  puts "Utilisateur créé : #{user.first_name} #{user.last_name} (#{user.email})"
end

puts "Création des sloopies..."
10.times do |i|
  duration = [3, 5, 7, 10, 14, 30, 45, 60, 75, 90].sample
  budget = rand(10..150) * duration
  status = i < 2 ? "done" : %w[in_progress save deleted archived].sample

  if status == "done"
    departure_date = Date.today - rand(30..365)
    return_date = departure_date + duration
  else
    departure_date = Date.today + rand(0..365)
    return_date = departure_date + duration
  end

  origin = european_cities.sample
  destination = (european_cities - [origin]).sample

  sloopy = Sloopy.create!(
    origin: origin,
    destination: destination,
    departure_date: departure_date,
    return_date: return_date,
    budget: budget,
    duration: duration,
    status: status,
    user_id: users[i % users.size].id
  )

  puts "Sloopy créé : ID #{sloopy.id}, Origine #{origin}, Destination #{destination}, Durée #{duration} jours, Statut #{status}"

  num_steps = rand(2..10)
  remaining_days = duration
  cities_used = [origin] # Déjà utilisée, mais pas la destination

  steps = []
  destination_added = false

  num_steps.times do |j|
    possible_cities = european_cities - cities_used
    city_name = if j == num_steps - 1 || (!destination_added && remaining_days <= 7)
                  # Assurez que la destination est utilisée au moins une fois
                  destination_added = true
                  destination
                else
                  possible_cities.sample
                end
    cities_used << city_name

    if j == num_steps - 1
      step_duration = remaining_days
    else
      max_step_duration = [remaining_days - (num_steps - j - 1), 7].min
      step_duration = max_step_duration > 0 ? rand(1..max_step_duration) : 1
    end

    remaining_days -= step_duration

    steps << { city_name: city_name, step_duration: step_duration }
  end

  # Crée les étapes en base de données et affiche
  steps.each do |step_data|
    step = Step.create!(
      sloopy_id: sloopy.id,
      city_name: step_data[:city_name],
      step_duration: step_data[:step_duration]
    )
    puts "  Étape ajoutée : #{step.city_name}, Durée #{step.step_duration} jours"
  end

  unless sloopy.steps.sum(:step_duration) == sloopy.duration
    raise "Erreur : La somme des durées des étapes ne correspond pas à la durée totale du sloopy ID #{sloopy.id}"
  end

  if sloopy.status == "done"
    review = Review.create!(
      content: "Voyage incroyable, des souvenirs inoubliables!",
      rating: rand(4..5),
      sloopy_id: sloopy.id
    )
    puts "  Review ajoutée : #{review.content} (Note : #{review.rating})"
  end
end

puts "Création des préférences des utilisateurs..."
all_preferences = {
  "budget" => (10..100).step(10).map(&:to_s),
  "activities" => ["sport", "museum", "hiking", "beach", "shopping", "concert", "theater", "photography"],
  "food" => ["italian", "vegan", "fast food", "local", "gourmet", "asian", "mediterranean", "street food"],
  "accommodation" => ["hotel", "hostel", "airbnb", "apartment", "camping", "resort"],
  "transport" => ["bus", "train", "plane", "car", "bike", "boat"]
}

users.each do |user|
  selected_categories = all_preferences.keys.sample(rand(1..4))

  selected_categories.each do |category|
    choice = all_preferences[category].sample
    created_preference = Preference.create!(category: category, choice: choice)
    user.user_preferences.create!(preference_id: created_preference.id)
    puts "Préférence ajoutée pour #{user.first_name} : Catégorie #{category}, Choix #{choice}"
  end
end

puts "Préférences des utilisateurs créées avec succès."
puts "Nouvelle seed créée avec succès."
