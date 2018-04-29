class CourseCategory < ActiveRecord::Base
  belongs_to :user
  has_many :custom_activities, dependent: :destroy
  has_many :parameters, dependent: :destroy, foreign_key: "course_category_id", class_name: "CourseCategoryParameter"
end
