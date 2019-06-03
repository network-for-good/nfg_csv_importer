class CreateOnboardingRelatedObject < ActiveRecord::Migration[5.2]
  def change
    create_table "onboarding_related_objects", force: :cascade do |t|
      t.string  "name",                  :limit=>255
      t.integer "target_id",             :limit=>4
      t.string  "target_type",           :limit=>255
      t.integer "onboarding_session_id", :limit=>4, :index=>{:name=>"index_onboarding_related_objects_on_onboarding_session_id", :using=>:btree}, :foreign_key=>{:references=>"onboarding_sessions", :name=>"fk_onboarding_related_objects_onboarding_session_id", :on_update=>:restrict, :on_delete=>:restrict}
    end
  end
end
