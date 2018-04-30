class CourseCategory < ActiveRecord::Base
  belongs_to :user
  has_many :activities, dependent: :destroy, foreign_key: "course_category_id", class_name: "CustomActivity"
  has_many :parameters, dependent: :destroy, foreign_key: "course_category_id", class_name: "CourseCategoryParameter"
end
