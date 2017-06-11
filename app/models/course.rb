class Course < ActiveRecord::Base
  has_one :course_category
  has_and_belongs_to_many :users, join_table: :users_courses

end
