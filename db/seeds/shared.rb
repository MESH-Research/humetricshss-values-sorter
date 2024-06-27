# frozen_string_literal: true

# TRICKY: This script may be run in environments where database entries persist between runs. All code in this file and
# the other seed files should be idempotent to avoid possible errors

# Main library seed
puts "\n== Ensuring main Library exists =="
main_library = Library.find_or_create_by!(id: Library::MAIN_LIBRARY_ID)

# Activity seeds
if main_library.activities.none?
  activity_data = [
    ["creating a digital project", "fas fa-laptop"],
    ["editing a journal", "fas fa-pencil-alt"],
    ["putting on an exhibit", "fas fa-chalkboard-teacher"],
    ["writing a book", "fas fa-book"],
    ["creating a syllabus", "fas fa-clipboard-list"]
  ]

  puts "\n== No Activities found - seeding Activities =="
  activity_data.each do |name, icon_class|
    Activity.create!(
      library: main_library,
      name: name,
      icon_class: icon_class
    )
  end
end

# Value seeds
if main_library.values.none?
  value_data = [
    ["collegiality", "fas fa-hand-holding-heart"],
    ["community", "fas fa-users"],
    ["equity", "fas fa-balance-scale"],
    ["openness", "fas fa-hands"],
    ["soundness", "fas fa-check-double"]
  ]

  puts "\n== No Values found - seeding Values =="
  value_data.each do |name, icon_class|
    Value.create!(
      library: main_library,
      name: name,
      icon_class: icon_class
    )
  end
end

# Admin seed
if User.none?
  puts "\n== Creating first admin =="
  puts "WARNING: This user should have their credentials edited as soon as possible"
  User.create!(
    first_name: "Bootstrap",
    last_name: "Admin",
    email: "admin@example.com",
    password: "password",
    password_confirmation: "password",
    role: :admin,
    terms_of_service: true
  )
end
