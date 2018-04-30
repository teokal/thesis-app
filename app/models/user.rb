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

  protected

  def email_required?
    false
  end
end
