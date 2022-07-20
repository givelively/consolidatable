ActiveRecord::Schema.define do
  self.verbose = false

  create_table "consolidations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "consolidatable_id", null: false
    t.string "consolidatable_type", null: false
    t.string "var_name", null: false
    t.string "var_type", null: false
    t.float "float_value"
    t.integer "integer_value"
    t.boolean "boolean_value"
    t.string "string_value"
    t.datetime "datetime_value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end
end
