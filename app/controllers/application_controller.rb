require "elasticsearch"

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :authenticate_user!
  protect_from_forgery with: :exception

  ES_CONTROLLER = EsController.new
  MODULES_OF_INTEREST = %w(assignment quiz forum scorm resource page folder url)

  def index
  end

  def generate_csrf_token
    app_controller = ActionController::Base::ApplicationController.new
    app_controller.request = ActionDispatch::Request.new({})
    app_controller.send(:form_authenticity_token)
  end

  def course_params_serializer(user, course_id)
    course_categories = user.course_categories
      .where(course_id: course_id, final: true, deleted: false)
      .where.not(name: "None")
    constants = user.parameters.where(course_id: course_id, constant: true)

    params_serialized = course_categories.map { |category|
      cat = {
        category_id: category.id,
        category_name: category.name,
      }

      category.parameters.each { |param|
        cat.merge!(Hash[param.series, param.value])
      }

      cat
    }

    cnsts_serialized = Hash[constants.collect { |c| [c.series, c.value] }]

    return {
             parameters: params_serialized,
             constants: cnsts_serialized,
           }
  end
end
