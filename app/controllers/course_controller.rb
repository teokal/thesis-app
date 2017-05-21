class CourseController < ApplicationController

  def index
    @courses = Course.all
  end

  def show
    @course = Course.find_by(id: params[:id])
  end

  def show_moodle
    @course = Course.find_by(moodle_id: params[:id])
    render 'course/show'
  end

end
