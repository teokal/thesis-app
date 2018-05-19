class CourseController < ApplicationController
  def get_logs
    queries = params[:query].split(",")
    data_table = []
    keys = params[:query] == "all" ? %w(viewed) : queries
    keys.each do |query|
      data_table << Hash[query, ES_CONTROLLER.query_es({from_date: params[:from_date], to_date: params[:to_date],
                                                        query: query, view: params[:view], module: params[:module],
                                                        course_id: params[:course], module_id: params[:module_id]})]
    end

    data_t = ES_CONTROLLER.transform_response(data_table, keys)
    {data: data_t}
  rescue => error
    Rails.logger.error("[ERROR] Courses | get_logs | error: " + error.message.inspect)
    {status: :error, type: :bad_request}
  end

  def get_course_contents
    sections = Moodle::Api.core_course_get_contents(courseid: params[:courseid], options: [{:name => "excludemodules", :value => "false"}])
    if sections.blank?
      {type: :error, message: "Course not found or has no content"}
    else
      course_total_modules_contents_counter = 0
      course_total_modules_contents = []

      sections.each_with_index { |section, s_i|
        if sections[s_i]["modules"].length != 0
          section["modules"].each_with_index { |module_, m_i|
            if !module_["contents"].nil? && module_["contents"].length != 0
              course_total_modules_contents_counter += module_["contents"].length
              course_total_modules_contents << module_["contents"]
              sections[s_i]["modules"][m_i]["contents"] = {
                data: module_["contents"],
                statistics: {
                  counter: module_["contents"].length,
                  filetypes: calc_perc_from_filenames(module_["contents"]),
                },
              }
            else
              sections[s_i]["modules"][m_i]["contents"] = {
                data: [],
                statistics: {
                  counter: 0,
                  filetypes: [],
                },
              }
            end
          }

          sections[s_i]["modules"] = {
            data: sections[s_i]["modules"],
            statistics: {
              counter: sections[s_i]["modules"].map { |m| m["contents"][:statistics][:counter] }.inject(0, :+),
              filetypes: calc_perc_from_filenames(sections[s_i]["modules"].map { |m| m["contents"][:data] }),
            },
          }
        else
          sections[s_i]["modules"] = {data: [], statistics: {
            counter: 0,
            filetypes: [],
          }}
        end
      }

      course_total_modules_contents = course_total_modules_contents
        .flatten
        .select { |c| c["type"] == "file" }

      {
        data: {
          contents: sections,
          total_files: course_total_modules_contents.count,
          filetypes: calc_perc_from_filenames(course_total_modules_contents),
        },
      }
    end
  end

  def get_course_modules
    modules = Moodle::Api.core_course_get_course_module(cmid: params[:cmid])
    modules.blank? ? {type: :error, message: "Course not found"} : modules
    {data: modules}
  end

  def enrolled_users
    enrolled_users = MoodleController.enrolled_users(params[:courseid])
    if enrolled_users.blank?
      {type: :error, message: "Course not found or does not have enrolled users"}
    else
      {data: enrolled_users}
    end
  end

  def calc_perc_from_filenames(contents = nil)
    begin
      if !contents.blank?
        contents
          .map { |c| custom_file_naming(File.extname(c["filename"]).delete(".")) }
          .group_by { |x| x }
          .map { |k, v| {type: k, counter: v.count} }
      else
        []
      end
    rescue => e
      []
    end
  end

  def custom_file_naming(name)
    return "PDF/Word Files" if name.in? %w(pdf PDF Pdf doc docx txt rdf)
    return "Excel Files" if name.in? %w(xls xlsm xlsx xlsmx csv tsv)
    return "Presentations" if name.in? %w(ppt pptx pptm ppsm pps odp)
    return "HTML Files" if name.in? %w(html xml htm)
    return "Video Files" if name.in? %w(mp4 mpeg mpg mov wmv)
    return "Audio Files" if name.in? %w(mp3 mp2 wav)
    return "Image Files" if name.in? %w(jpeg jpg png svg bmp)
    return "#{name.upcase} Files"
  end

  def custom_categories_graph(user)
    course_id = params[:course_id].to_i
    moodle_activities = MoodleController.contents(course_id).map { |s| Hash[s[:id], s[:title]] }.reduce({}, :merge)

    categories = user.course_categories.preload(:activities).where(course_id: course_id, final: true).order("name = \"None\"")
    default_category = categories.find_by(name: "None", final: true, course_id: course_id)

    if user.initialize_custom_activities(moodle_activities, default_category)
      if categories.count > 0
        {
          data: categories.map { |category|
            {
              category_id: category.id,
              category_name: category.name,
              counter: category.activities&.count,
            }
          },
        }
      else
        {type: :error, message: "This course does not have categories"}
      end
    else
      Rails.logger.error("[ERROR] Courses | custom_categories_graph | Failed to initialize custom activities")
      {type: :error, status: :internal_error}
    end
  end

  # CATEGORY PARAMETERS
  def parameters_index(user)
    user.initialize_course_categories(params[:course_id].to_i)

    course_params_serializer(user, params[:course_id])
  rescue => error
    Rails.logger.debug(error.message)
  end

  def parameters_update(user)
    if (!params[:course_id].blank? && (params[:course_id].to_i != 0) && !params[:parameters].blank?)
      cc = user.course_categories.preload(:parameters).where(course_id: params[:course_id].to_i, deleted: false).order("name = \"None\"")
      user_course_constants = user.parameters.where(course_id: params[:course_id], constant: true)

      params[:parameters].map { |p|
        begin
          selected_cc = cc.find(p[:category_id])
          p.delete(:category_id)
          p.delete(:category_name)

          p.keys.each { |k|
            param = selected_cc.parameters.find_by(series: k.to_i)
            if !param.blank?
              param.value = p[k]
              param.save
            else
              selected_cc.parameters.create(value: p[k], series: k.to_i, constant: false,
                                            course_id: selected_cc.course_id, user_id: user.id)
            end
          }
        rescue => error
          Rails.logger.debug(error.message)
          next
        end
      }

      params[:constants].each { |k, v|
        begin
          cnst = user_course_constants.find_by(series: k.to_i)
          if !cnst.blank?
            cnst.value = v
            cnst.save
          else
            CourseCategoryParameter.create(user_id: user.id, value: v, series: k.to_i,
                                           course_id: params[:course_id], constant: true)
          end
        rescue => error
          Rails.logger.debug(error.message)
          next
        end
      }

      course_params_serializer(user, params[:course_id])
    else
      return {type: :error}
    end
  rescue => error
    Rails.logger.debug(error.message)
  end
end
