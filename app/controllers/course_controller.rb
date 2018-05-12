class CourseController < ApplicationController
  def get_logs
    queries = params[:query].split(",")
    data_table = []
    keys = params[:query] == "all" ? %w(viewed) : queries
    keys.each do |query|
      data_table << Hash[query, ES_CONTROLLER.query_es({from_date: params[:from_date], to_date: params[:to_date],
                                                        query: query, view: params[:view], module: "course", course_id: params[:course]})]
    end

    data_t = ES_CONTROLLER.transform_response(data_table, keys)
    {data: data_t}
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
    enrolled_users = Moodle::Api.core_enrol_get_enrolled_users(courseid: params[:courseid], options: [{:name => "userfields", :value => "fullname"}])
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
    course_scorms = Moodle::Api.mod_scorm_get_scorms_by_courses(courseids: Array(params[:course_id]))
    moodle_activities = course_scorms["scorms"].map { |s| Hash[s["launch"], s["name"]] }.flatten.reduce({}, :merge)

    categories = user.course_categories.preload(:activities).where(course_id: params[:course_id], final: true)
    default_category = categories.find_by(name: "None")
    user.initialize_custom_activities(moodle_activities, default_category)

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
  end
end
