class CourseCategoryController < ApplicationController
  def index(user)
    if (!params[:course_id].blank? && (params[:course_id].to_i != 0))
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
       (!params[:name].downcase.in? %w(id title name))
      cc = user.course_categories.new(
        course_id: params[:course_id],
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

    if cc
      cc.update(deleted: true)
    else
      {type: :error}
    end
  rescue => error
    Rails.logger.debug(error.message)
  end

  # CATEGORY PARAMETERS
  def parameters_index(user)
    cc = user.course_categories.preload(:parameters).where(course_id: params[:course_id])
    categories_w_params_serializer(cc)
  rescue => error
    Rails.logger.debug(error.message)
  end

  def parameters_update(user)
    if (!params[:course_id].blank? && (params[:course_id].to_i != 0) && !params[:parameters].blank?)
      cc = user.course_categories.preload(:parameters).where(course_id: params[:course_id].to_i, deleted: false)
      params[:parameters].map { |p|
        begin
          selected_cc = cc.find(p[:category_id])
          p.delete(:category_id)

          p.keys.each { |k|
            param = selected_cc.parameters.find_by(series: k.to_i)
            if !param.blank?
              param.value = p[k]
              param.save
            else
              selected_cc.parameters.create(value: p[k], series: k.to_i)
            end
          }
        rescue => error
          next
        end
      }

      categories_w_params_serializer(cc)
    else
      {type: :error}
    end
  rescue => error
    Rails.logger.debug(error.message)
  end

  def categories_w_params_serializer(course_categories)
    course_categories.map { |category|
      cat = {
        category_id: category.id,
        category_name: category.name,
      }

      category.parameters.each { |param|
        cat.merge!(Hash[param.series, param.value])
      }

      cat
    }
  end
end
