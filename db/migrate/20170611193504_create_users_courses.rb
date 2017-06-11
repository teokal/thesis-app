class CreateUsersCourses < ActiveRecord::Migration
  def change
    create_table :users_courses do |t|
      t.integer :user_id, null: false
      t.integer :course_id, null: false
    end
  end
end

