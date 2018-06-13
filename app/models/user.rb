class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :courses, join_table: :users_courses

  has_many :course_categories, dependent: :destroy
  has_many :activities, dependent: :destroy, foreign_key: "user_id", class_name: "CustomActivity"
  has_many :parameters, dependent: :destroy, foreign_key: "user_id", class_name: "CourseCategoryParameter"

  has_secure_token :access_token

  def finalize_categories
    self.course_categories.where(user: self.id, final: false).update_all(final: true)
    self.course_categories.where(user: self.id, deleted: true).destroy_all
  rescue => error
    Rails.logger.debug(error.message)
  end

  def initialize_course_categories(course_id)
    cc = self.course_categories.where(course_id: course_id, final: true, deleted: false)
    unless cc.size > 0
      default_categories = %w(Slides Quiz Uncategorized).map { |cat|
        {
          course_id: course_id,
          name: cat,
          final: true,
        }
      }
      self.course_categories.create(default_categories)
    end
  end

  def initialize_custom_activities(moodle_activities, default_category)
    activities_ids = moodle_activities.keys
    existing_activities_ids = self.course_categories.where(course_id: default_category.course_id)
      .map { |cat| cat.activities.pluck(:activity_id) }.flatten

    removed_activity_ids = existing_activities_ids - activities_ids
    activities_ids -= existing_activities_ids

    default_category&.activities&.create(activities_ids.map { |actv_id| {activity_id: actv_id, user_id: self.id} })
    self.activities.where("activity_id IN (?) AND user_id = (?)", removed_activity_ids, self.id).destroy_all
    true
  rescue => error
    Rails.logger.debug("Could not initialize_custom_activities. Message: #{error.message.inspect}")
    false
  end

  def has_initialized_course?(course_id)
    counter = self.course_categories.where(course_id: course_id, final: true).map(&:activities).count
    (counter == 0) ? false : true
  end

  protected

  def email_required?
    false
  end
end
