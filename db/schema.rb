# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_01_26_154813) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "icon_class"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "library_id", null: false
    t.index ["library_id"], name: "index_activities_on_library_id"
  end

  create_table "advice", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "activity_id", null: false
    t.uuid "value_id", null: false
    t.string "text", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "library_id", null: false
    t.string "attribution", default: "", null: false
    t.integer "published_state", default: 1, null: false
    t.index ["activity_id", "value_id"], name: "index_advice_on_activity_id_and_value_id"
    t.index ["activity_id"], name: "index_advice_on_activity_id"
    t.index ["library_id"], name: "index_advice_on_library_id"
    t.index ["value_id"], name: "index_advice_on_value_id"
  end

  create_table "advice_submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "source_advice_id"
    t.uuid "published_advice_id"
    t.string "author_name", default: "", null: false
    t.string "custom_activity", default: "", null: false
    t.uuid "published_activity_id"
    t.string "custom_value", default: "", null: false
    t.uuid "published_value_id"
    t.string "text", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "submitted_text", null: false
    t.index ["published_activity_id"], name: "index_advice_submissions_on_published_activity_id"
    t.index ["published_advice_id"], name: "index_advice_submissions_on_published_advice_id"
    t.index ["published_value_id"], name: "index_advice_submissions_on_published_value_id"
    t.index ["source_advice_id"], name: "index_advice_submissions_on_source_advice_id"
  end

  create_table "contributor_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.text "discovery", null: false
    t.text "interest", null: false
    t.text "perspective", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_contributor_applications_on_user_id", unique: true
  end

  create_table "libraries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "owner_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "sharing_code", default: -> { "gen_random_uuid()" }, null: false
    t.index ["owner_id"], name: "index_libraries_on_owner_id", unique: true
    t.index ["sharing_code"], name: "index_libraries_on_sharing_code"
  end

  create_table "library_guests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "library_id"
    t.uuid "guest_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["guest_id"], name: "index_library_guests_on_guest_id"
    t.index ["library_id"], name: "index_library_guests_on_library_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.integer "role", default: 0, null: false
    t.boolean "terms_of_service", null: false
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "values", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "icon_class"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "library_id", null: false
    t.index ["library_id"], name: "index_values_on_library_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "libraries"
  add_foreign_key "advice", "\"values\"", column: "value_id"
  add_foreign_key "advice", "activities"
  add_foreign_key "advice", "libraries"
  add_foreign_key "advice_submissions", "\"values\"", column: "published_value_id"
  add_foreign_key "advice_submissions", "activities", column: "published_activity_id"
  add_foreign_key "advice_submissions", "advice", column: "published_advice_id"
  add_foreign_key "advice_submissions", "advice", column: "source_advice_id"
  add_foreign_key "contributor_applications", "users"
  add_foreign_key "libraries", "users", column: "owner_id"
  add_foreign_key "library_guests", "libraries"
  add_foreign_key "library_guests", "users", column: "guest_id"
  add_foreign_key "values", "libraries"
end
