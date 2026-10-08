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

ActiveRecord::Schema[8.1].define(version: 2026_10_06_075720) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["username"], name: "index_admins_on_username", unique: true
  end

  create_table "appointments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "customer_id"
    t.string "description"
    t.integer "employee_id", null: false
    t.datetime "ends_at", null: false
    t.integer "enterprise_id", null: false
    t.integer "pet_id"
    t.integer "room_id", null: false
    t.datetime "starts_at", null: false
    t.integer "store_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_appointments_on_customer_id"
    t.index ["employee_id"], name: "index_appointments_on_employee_id"
    t.index ["enterprise_id"], name: "index_appointments_on_enterprise_id"
    t.index ["pet_id"], name: "index_appointments_on_pet_id"
    t.index ["room_id", "starts_at"], name: "index_appointments_on_room_id_and_starts_at"
    t.index ["room_id"], name: "index_appointments_on_room_id"
    t.index ["store_id"], name: "index_appointments_on_store_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["customer_id"], name: "index_conversations_on_customer_id"
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "address"
    t.date "born_on"
    t.datetime "created_at", null: false
    t.string "document_number"
    t.string "document_type"
    t.string "email"
    t.integer "enterprise_id", null: false
    t.string "first_name"
    t.string "first_phone"
    t.string "first_surname"
    t.string "post_code"
    t.string "province"
    t.string "second_phone"
    t.string "second_surname"
    t.string "sex"
    t.datetime "updated_at", null: false
    t.index ["enterprise_id"], name: "index_customers_on_enterprise_id"
  end

  create_table "employees", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.integer "enterprise_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest", null: false
    t.string "phone"
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_employees_on_email_address", unique: true
    t.index ["enterprise_id"], name: "index_employees_on_enterprise_id"
  end

  create_table "enterprises", force: :cascade do |t|
    t.string "address"
    t.string "cif"
    t.datetime "created_at", null: false
    t.string "legal_name"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer "conversation_id"
    t.datetime "created_at", null: false
    t.string "delivery_status"
    t.integer "sender"
    t.string "text"
    t.datetime "updated_at", null: false
    t.string "whatsapp_message_id"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["whatsapp_message_id"], name: "index_messages_on_whatsapp_message_id"
  end

  create_table "pets", force: :cascade do |t|
    t.date "born_on"
    t.string "breed"
    t.string "color"
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.string "name"
    t.string "notes"
    t.string "sex"
    t.string "species"
    t.string "transponder_location"
    t.string "transponder_number"
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_pets_on_customer_id"
  end

  create_table "product_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "enterprise_id", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["enterprise_id"], name: "index_product_categories_on_enterprise_id"
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.integer "enterprise_id", null: false
    t.string "name"
    t.decimal "price", precision: 7, scale: 2
    t.integer "product_category_id", null: false
    t.datetime "updated_at", null: false
    t.index ["enterprise_id"], name: "index_products_on_enterprise_id"
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "store_id", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_rooms_on_store_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "employee_id", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["employee_id"], name: "index_sessions_on_employee_id"
  end

  create_table "stores", force: :cascade do |t|
    t.string "address"
    t.string "color"
    t.datetime "created_at", null: false
    t.integer "enterprise_id", null: false
    t.string "name"
    t.string "post_code"
    t.datetime "updated_at", null: false
    t.index ["enterprise_id"], name: "index_stores_on_enterprise_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "phone"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appointments", "customers"
  add_foreign_key "appointments", "employees"
  add_foreign_key "appointments", "enterprises"
  add_foreign_key "appointments", "pets"
  add_foreign_key "appointments", "rooms"
  add_foreign_key "appointments", "stores"
  add_foreign_key "conversations", "customers"
  add_foreign_key "conversations", "users"
  add_foreign_key "customers", "enterprises"
  add_foreign_key "employees", "enterprises"
  add_foreign_key "messages", "conversations"
  add_foreign_key "pets", "customers"
  add_foreign_key "product_categories", "enterprises"
  add_foreign_key "products", "enterprises"
  add_foreign_key "products", "product_categories"
  add_foreign_key "rooms", "stores"
  add_foreign_key "sessions", "employees"
  add_foreign_key "stores", "enterprises"
end
