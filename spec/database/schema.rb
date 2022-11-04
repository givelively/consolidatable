# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table 'consolidations', force: :cascade do |t|
    t.uuid 'consolidatable_id', null: false
    t.string 'consolidatable_type', null: false
    t.string 'var_name', null: false
    t.string 'var_type', null: false
    t.float 'float_value'
    t.bigint 'integer_value'
    t.boolean 'boolean_value'
    t.string 'string_value'
    t.datetime 'datetime_value'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index %w[consolidatable_id consolidatable_type var_name],
            name: 'consolidations_main_index'
  end

  create_table 'children',
               id: :uuid,
               default: -> { 'gen_random_uuid()' },
               force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'presents',
               id: :uuid,
               default: -> { 'gen_random_uuid()' },
               force: :cascade do |t|
    t.uuid 'child_id'
    t.string 'name'
    t.float 'weight'
    t.integer 'price'
    t.boolean 'cute'
    t.datetime 'produced_at'

    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end
end
