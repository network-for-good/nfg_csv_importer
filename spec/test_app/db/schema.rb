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

ActiveRecord::Schema.define(version: 2023_03_28_001336) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.integer "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "entities", force: :cascade do |t|
    t.string "subdomain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nfg_csv_importer_imported_records", force: :cascade do |t|
    t.integer "imported_for_id"
    t.integer "imported_by_id"
    t.string "action"
    t.integer "importable_id"
    t.string "importable_type"
    t.string "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "import_id"
    t.boolean "deleted", default: false
    t.text "row_data"
    t.index ["import_id"], name: "index_nfg_csv_importer_imported_records_on_import_id"
  end

  create_table "nfg_csv_importer_imports", force: :cascade do |t|
    t.string "import_type"
    t.string "import_file"
    t.string "error_file"
    t.integer "number_of_records"
    t.integer "number_of_records_with_errors"
    t.integer "imported_for_id"
    t.integer "imported_by_id"
    t.integer "status"
    t.integer "records_processed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "fields_mapping"
    t.string "import_file_name"
    t.datetime "processing_started_at"
    t.datetime "processing_finished_at"
    t.string "file_origination_type"
    t.string "statistics"
  end

  create_table "onboarding_related_objects", force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "target_id", limit: 4
    t.string "target_type", limit: 255
    t.integer "onboarding_session_id", limit: 4
    t.index ["onboarding_session_id"], name: "index_onboarding_related_objects_on_onboarding_session_id"
  end

  create_table "onboarding_sessions", force: :cascade do |t|
    t.text "completed_high_level_steps", limit: 65535
    t.string "current_step", limit: 255
    t.integer "owner_id", limit: 4
    t.integer "entity_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "step_data", limit: 65535
    t.string "current_high_level_step", limit: 255
    t.text "onboarder_progress", limit: 65535
    t.string "owner_type", limit: 255
    t.datetime "completed_at"
    t.string "onboarder_prefix", limit: 255
    t.string "name", limit: 255
    t.index ["entity_id"], name: "fk__onboarding_sessions_entity_id"
    t.index ["name"], name: "index_onboarding_sessions_on_name"
    t.index ["owner_id"], name: "fk__onboarding_sessions_owner_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "cause_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.integer "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "note"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
