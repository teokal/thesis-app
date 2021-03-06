require "elasticsearch"

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :authenticate_user!, except: [:index]
  protect_from_forgery with: :exception

  ES_CONTROLLER = EsController.new
  MODULES_OF_INTEREST = %w(assignment quiz forum scorm resource page folder url)

  def index
    render :json => {:errors => "This is an API-only application. Use routes as given on documentation."}, :status => :bad_request
  end

  def course_params_serializer(user, course_id)
    course_categories = user.course_categories
      .where(course_id: course_id, final: true, deleted: false)
      .where.not(name: "Uncategorized")
    constants = user.parameters.where(course_id: course_id, constant: true)

    params_serialized = course_categories.map { |category|
      cat = {
        category_id: category.id,
        category_name: category.name,
      }

      if category.parameters.count > 0
        category.parameters.each { |param|
          cat.merge!(Hash[param.series, param.value])
        }
      else
        cat.merge!(Hash[1, 0])
        cat.merge!(Hash[2, 0])
      end

      cat
    }

    cnsts_serialized = Hash[constants.collect { |c| [c.series, c.value] }]

    return {
             parameters: params_serialized,
             constants: cnsts_serialized,
           }
  end
end
