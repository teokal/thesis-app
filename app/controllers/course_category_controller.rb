class CourseCategoryController < ApplicationController
  def index(user)
    if (!params[:course_id].blank? && (params[:course_id].to_i != 0))
      user.initialize_course_categories(params[:course_id].to_i)

      cc = user.course_categories.where(course_id: params[:course_id].to_i, final: true, deleted: false)

      cc.as_json(only: [:id, :name])
    else
      {type: :error}
    end
  rescue => error
    Rails.logger.debug(error.message)
  end

  def create(user)
    if !params[:course_id].blank? && !params[:name].blank? &&
       (!params[:name].downcase.in? %w(id title name none))
      cc = user.course_categories.new(
        course_id: params[:course_id].to_i,
        name: params[:name],
      )

      if cc.save
        cc.as_json(only: [:id, :name])
      else
        {type: :error}
      end
    else
      {type: :error}
    end
  rescue => error
    Rails.logger.debug(error.message)
  end

  def delete(user)
    cc = user.course_categories.find_by_id(params[:id])

    if cc && (cc.name.downcase != "none")
      cc.update(deleted: true)
      return {deleted: true}
    else
      return {type: :error}
    end
  rescue => error
    Rails.logger.debug(error.message)
  end
end
