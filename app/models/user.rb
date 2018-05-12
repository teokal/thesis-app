class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :courses, join_table: :users_courses

  has_many :course_categories, dependent: :destroy
  has_many :activities, dependent: :destroy, foreign_key: "user_id", class_name: "CustomActivity"

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
      default_categories = %w(Slides Quiz None).map { |cat|
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
    moodle_activities.each { |a|
      activity_id = a.first
      actv = self.activities.preload(:category).find_by(activity_id: activity_id)

      unless actv
        default_category&.activities&.create(
          activity_id: activity_id,
          user: self,
        )
      end
    }
  end

  protected

  def email_required?
    false
  end
end
