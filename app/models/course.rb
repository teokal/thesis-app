class Course < ActiveRecord::Base
  belongs_to :course_category , :class_name => 'CourseCategory', :foreign_key => 'moodle_id'
  has_and_belongs_to_many :users, join_table: :users_courses

end
