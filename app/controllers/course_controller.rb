class CourseController < ApplicationController

  def index
    Course.all
  end

  def show(id)
    course = Course.find_by(id: id)
    course.nil? ? {type: :error, message: 'Course not found'} : course
  end

  def show_moodle(id)
    course = Course.find_by(moodle_id: id)
    course.nil? ? {type: :error, message: 'Course not found'} : course
  end

end
