class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :courses, join_table: :users_courses

  def add_course(course)
    course = Course.find_by(id: course)
    courses << course if course
  end

  def remove_course(course)
    course = courses.find(course)
    courses.delete(course) if course
  end

end
