class CourseCategoryParameter < ActiveRecord::Base
  belongs_to :category, foreign_key: "course_category_id", class_name: "CourseCategory"
end
