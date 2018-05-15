class UserController < ApplicationController
  def info(user = nil, user_ids = nil)
    if user_ids.nil?
      array_user_ids = Array(user.moodle_user_id)
    else
      # [1,2,3,4]
      if user_ids.class != String && user_ids.all? { |i| i.is_a?(Integer) }
        array_user_ids = user_ids
      else # "1" -> [1]|| "1,2,3,4" -> [1,2,3,4]
        array_user_ids = user_ids.split(",").map(&:to_i)
      end
    end

    user = Moodle::Api.core_user_get_users_by_field(field: "id", values: array_user_ids)
    user.blank? ? {type: :error, message: "User not found"} : user
  end

  def courses(user)
    courses = Moodle::Api.core_enrol_get_users_courses(userid: user.moodle_user_id)
    courses.blank? ? {type: :error, message: "No courses found"} : courses
  end

  def statistics(user)
    courses = Moodle::Api.core_enrol_get_users_courses(userid: user.moodle_user_id)

    total_students = 0
    statistics = []
    key = "viewed"

    from_date = params[:from_date].blank? ? DateTime.now.prev_year.strftime("%d-%m-%Y") : params[:from_date]
    to_date = params[:to_date].blank? ? DateTime.now.strftime("%d-%m-%Y") : params[:to_date]
    view = params[:view].blank? ? "month" : params[:view]

    total_students = courses.map { |course| course["enrolledusercount"] }.inject(0) { |sum, x| sum + x }

    es_stats = ES_CONTROLLER.query_es({from_date: from_date, to_date: to_date,
                                       query: key, view: view, module: "course",
                                       course_id: courses.map { |course| course["id"] }})

    statistics << Hash[key, es_stats]
    {
      enrolledusercount: total_students,
      viewed: ES_CONTROLLER.transform_response(statistics, [key]),
    }
  end

  def logs
    queries = params[:query].split(",")
    data_table = []
    keys = ((params[:query] == "all") ? %w(update logout login view add) : queries)
    keys.each do |query|
      data_table << Hash[query, es_controller.query_es({from_date: params[:from_date], to_date: params[:to_date],
                                                        query: query, view: params[:view], module: "user"})]
    end

    {data: ES_CONTROLLER.transform_response(data_table, keys)}
  end

  def logout
    begin
      @user.logout({destroy: true, token: params[:token]})
    rescue => error
      Rails.logger.error("[ERROR] API | Users | logout: " + error.message)
    end
  end

  def send_message(user)
    begin
      if params[:message].length == 0
        return {type: :error, message: "Message is empty."}
      else
        if params[:student_ids].count >= 1
          Moodle::Api.configuration.token = user.moodle_token
          result = Moodle::Api.core_message_send_instant_messages(
            messages: params[:student_ids].map { |id|
              {
                touserid: Integer(id),
                text: params[:message],
                textformat: 1,
              }
            },
          )
          Moodle::Api.configuration.token = ENV["MOODLE_TOKEN"]
          return "#{"Message".pluralize(params[:student_ids].count)} sent."
        else
          return {type: :error, message: "No students were selected to send this message."}
        end
      end
    rescue => error
      Rails.logger.error("[ERROR] API | Users | send_message: " + error.message)
    end
  end

  def custom_activities_index(user)
    begin
      course_id = params[:course_id].to_i
      moodle_activities = MoodleController.contents(course_id).map { |s| Hash[s[:id], s[:title]] }.reduce({}, :merge)

      categories = user.course_categories.preload(:activities).where(course_id: course_id, final: true)
      default_category = categories.find_by(name: "None")

      if user.initialize_custom_activities(moodle_activities, default_category)
        activities = categories.map(&:activities).flatten
        return activities.map { |activity|
                 actvt = {
                   id: activity.id,
                   title: moodle_activities[activity.activity_id],
                 }

                 categories.each { |category|
                   actvt.merge!(Hash[category.id, activity.category.id == category.id ? true : false])
                 }

                 actvt
               }
      else
        Rails.logger.error("[ERROR] Users | custom_activities_index | Failed to initialize custom activities")
        {type: :error, status: :internal_error}
      end
    rescue => error
      Rails.logger.error("[ERROR] Users | custom_activities_index: " + error.message)
      {type: :error, status: :internal_error}
    end
  end

  def custom_activities_update(user)
    begin
      user.finalize_categories
      activities = user.activities.joins(:category).where("course_categories.course_id = ?", params[:course_id])

      default_category = user.course_categories.find_by(name: "None", final: true, course_id: params[:course_id])
      params[:activities].each { |a|
        selected_category = nil

        act = activities.find_by(id: a["id"])
        a.delete("id")
        a.delete("title")

        a.each { |k, v|
          if v == true
            selected_category = user.course_categories.find_by_id(k)
            break
          end
        }

        if selected_category.nil?
          selected_category = default_category
        end

        act.category = selected_category
        unless act.save
          next
        end
      }

      return {saved: true}
    rescue => error
      Rails.logger.error("[ERROR] API | Users | custom_activities_update: " + error.message)
      return {type: :error, message: "There were some errors while saving. Please refresh and try again."}
    end
  end
end
