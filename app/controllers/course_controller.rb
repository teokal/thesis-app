class CourseController < ApplicationController

  def index
    Course.all
  end

  def show(id)
    Course.find_by(id: id)
  end

  def show_moodle(id)
    Course.find_by(moodle_id: id)
  end

end
