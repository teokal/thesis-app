class UserController < ApplicationController
  before_action :set_user

  def index
    User.all
  end

  def show(user)
    user.nil? ? {type: :error, message: 'User not found'} : user.as_json(only: [:id, :email])
  end

  def courses(user)
    unless user.nil?
      courses = user.courses
      if courses.blank?
        {type: :error, message: 'User has no courses'}
      else
        {courses: courses.as_json(only: [:id, :coursecategory, :fullname, :shortname, :idnumber, :summary, :timecreated]) }
      end
    end
  end

  private
  def set_user
    @user = User.find_by(id: params[:id])
    error_response(message: 'User not found') if @user.nil?
  end

end
