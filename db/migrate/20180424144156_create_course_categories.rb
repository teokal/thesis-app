class CreateCourseCategories < ActiveRecord::Migration
  def change
    create_table :course_categories do |t|
      t.integer :course_id
      t.string :name
      t.references :user, index: true
      t.boolean :final, default: false
      t.boolean :deleted, default: false
      t.timestamps null: false
    end
  end
end
