class CreateCustomActivities < ActiveRecord::Migration
  def change
    create_table :custom_activities do |t|
      t.integer :activity_id
      t.references :user, index: true
      t.references :course_category, index: true
    end
  end
end
