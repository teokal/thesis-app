class CreateCourseCategoryParameters < ActiveRecord::Migration
  def change
    create_table :course_category_parameters do |t|
      t.float :value
      t.integer :series
      t.references :course_category, index: true
    end
  end
end
