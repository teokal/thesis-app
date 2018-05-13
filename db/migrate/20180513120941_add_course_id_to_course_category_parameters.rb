class AddCourseIdToCourseCategoryParameters < ActiveRecord::Migration
  def up
    change_table :course_category_parameters do |t|
      t.change :value, :float, null: false
      t.change :series, :integer, null: false
      t.column :constant, :boolean, null: false, default: false
      t.column :course_id, :integer, null: false, index: true
      t.references :user, index: true, foreign_key: true
    end

    CourseCategoryParameter.where.not(category: nil).each do |param|
      param.course_id = param.category.course_id
      param.user = param.category.user
      param.save
    end
  end

  def down
    change_table :course_category_parameters do |t|
      t.remove :constant
      t.remove :course_id
      t.remove_references :user, index: true
    end
  end
end
