# frozen_string_literal: true

# This file should bootstrap all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# TRICKY: We want to share some seeds across environments and some only in particular environments. We use a shared
# file for the former, and environment-specific files for the latter

puts "\n== Seeding the database =="

puts "\n== Loading shared seeds =="

shared_seeds_path = Rails.root.join("db/seeds/shared.rb")
load(shared_seeds_path)

env_seeds_path = Rails.root.join("db/seeds/#{Rails.env}.rb")
if File.exist?(env_seeds_path)
  puts "\n== Loading #{Rails.env} seeds =="
  load(env_seeds_path)
end

puts "\n== Seeding complete =="
