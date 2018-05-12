class CourseCategory < ActiveRecord::Base
  belongs_to :user
  has_many :activities, foreign_key: "course_category_id", class_name: "CustomActivity"
  has_many :parameters, dependent: :destroy, foreign_key: "course_category_id", class_name: "CourseCategoryParameter"

  before_destroy :default_category

  def default_category
    activities = self.activities
    default_category_of_course = self.user.course_categories.find_by(name: "None", final: true, course_id: self.course_id)
    activities.update_all(course_category_id: default_category_of_course.id)
  end
end
