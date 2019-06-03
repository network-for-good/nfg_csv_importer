class CreateOnboardingSession < ActiveRecord::Migration[5.2]
  def change
    create_table "onboarding_sessions", force: :cascade do |t|
      t.text     "completed_high_level_steps", :limit=>65535
      t.string   "current_step",               :limit=>255
      t.integer  "owner_id",                    :limit=>4, :index=>{:name=>"fk__onboarding_sessions_owner_id", :using=>:btree}
      t.integer  "entity_id",                  :limit=>4, :index=>{:name=>"fk__onboarding_sessions_entity_id", :using=>:btree}, :foreign_key=>{:references=>"entities", :name=>"fk_onboarding_sessions_entity_id", :on_update=>:restrict, :on_delete=>:restrict}
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "step_data",                  :limit=>65535
      t.string   "current_high_level_step",    :limit=>255
      t.text     "onboarder_progress",         :limit=>65535
      t.string   "owner_type",                  :limit=>255
      t.datetime "completed_at"
      t.string   "onboarder_prefix",           :limit=>255
      t.string   "name",                       :limit=>255, :index=>{:name=>"index_onboarding_sessions_on_name", :using=>:btree}
    end
  end
end