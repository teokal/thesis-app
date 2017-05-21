class CreateCourseCategories < ActiveRecord::Migration
  def change
    create_table :course_categories do |t|
      t.string 'name', default: '', null: false
      t.string 'idnumber', limit: 100
      t.text 'description', limit: 2147483647
      t.integer 'descriptionformat', limit: 1, default: 0, null: false
      t.integer 'parent', limit: 8, default: 0, null: false
      t.integer 'sortorder', limit: 8, default: 0, null: false
      t.integer 'coursecount', limit: 8, default: 0, null: false
      t.boolean 'visible', default: true, null: false
      t.boolean 'visibleold', default: true, null: false
      t.integer 'timemodified', limit: 8, default: 0, null: false
      t.integer 'depth', limit: 8, default: 0, null: false
      t.string 'path', default: '', null: false
      t.string 'theme', limit: 50
      t.integer 'moodle_id', limit: 8, default: 0, null: false

      t.timestamps
    end
  end
end
