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

ActiveRecord::Schema[7.2].define(version: 2024_12_20_053238) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
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
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "containers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "number"
    t.string "size"
    t.string "container_type"
    t.string "cargo_owner"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_containers_on_created_at"
    t.index ["user_id"], name: "index_containers_on_user_id"
  end

  create_table "eirs", force: :cascade do |t|
    t.bigint "container_id", null: false
    t.string "operator"
    t.string "transport"
    t.string "plate"
    t.string "fleet_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "heavy"
    t.index ["container_id"], name: "index_eirs_on_container_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "total", precision: 10, scale: 2
    t.string "status", default: "Pending"
    t.date "issue_date"
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "location"
    t.boolean "available", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "moves", force: :cascade do |t|
    t.bigint "container_id", null: false
    t.string "move_type"
    t.string "status"
    t.string "mode"
    t.text "notes"
    t.string "images"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "seal"
    t.bigint "location_id"
    t.bigint "created_by_id"
    t.index ["container_id"], name: "index_moves_on_container_id"
    t.index ["location_id"], name: "index_moves_on_location_id"
    t.index ["move_type"], name: "index_moves_on_move_type"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "message"
    t.boolean "completed"
    t.bigint "move_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["move_id"], name: "index_notifications_on_move_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissions_roles", id: false, force: :cascade do |t|
    t.bigint "permission_id", null: false
    t.bigint "role_id", null: false
    t.index ["permission_id", "role_id"], name: "index_permissions_roles_on_permission_id_and_role_id"
    t.index ["role_id", "permission_id"], name: "index_permissions_roles_on_role_id_and_permission_id"
  end

  create_table "pricings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "service_id", null: false
    t.decimal "price", precision: 10, scale: 2
    t.integer "grace_period_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_pricings_on_service_id"
    t.index ["user_id"], name: "index_pricings_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "services", force: :cascade do |t|
    t.bigint "container_id"
    t.string "name"
    t.decimal "charge", precision: 10, scale: 2
    t.boolean "invoiced"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "invoice_id"
    t.index ["container_id"], name: "index_services_on_container_id"
    t.index ["invoice_id"], name: "index_services_on_invoice_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.string "second_last_name"
    t.string "contact_person"
    t.string "phone_number"
    t.integer "user_type"
    t.bigint "role_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "containers", "users"
  add_foreign_key "eirs", "containers"
  add_foreign_key "invoices", "users"
  add_foreign_key "moves", "containers"
  add_foreign_key "moves", "locations"
  add_foreign_key "notifications", "moves"
  add_foreign_key "pricings", "services"
  add_foreign_key "pricings", "users"
  add_foreign_key "services", "containers"
  add_foreign_key "services", "invoices"
  add_foreign_key "users", "roles"
end
