class CustomActivity < ActiveRecord::Base
  belongs_to :course_category
  belongs_to :user
end
