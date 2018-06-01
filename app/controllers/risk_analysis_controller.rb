class RiskAnalysisController < ApplicationController
  def get_risk_analysis
    course_id = params[:course_id].to_i

    enrolled_students = MoodleController.enrolled_users(course_id)
    if enrolled_students.blank?
      return {type: :error, message: "There are 0 enrolled users."}
    else
      enrolled_students = enrolled_students.map { |user| Hash[user["id"], user["fullname"]] }.reduce({}, :merge)
    end

    course_modules_details = MoodleController.contents(course_id)
    if course_modules_details.blank?
      return {type: :error, message: "Course does not have modules that belong on #{MODULES_OF_INTEREST.map { |w| w.pluralize }.join(", ").capitalize} categories."}
    end

    dates = {from: params[:from_date], to: params[:to_date]}
    completion_data = MoodleController.activities(course_id, enrolled_students, dates)
    if completion_data.blank?
      return {type: :error, message: "Course does not completion data"}
    else
      response_data = []
      course_modules = completion_data.map { |c| c["coursemoduleid"] }.uniq.sort

      completion_data.group_by { |r| r["userid"] }.map { |user_id, v|
        user_results = course_modules.product([false]).to_h
        Hash[user_id, v.map { |e|
               user_results[e["coursemoduleid"]] = (e["completionstate"] == (1 || 2) ? true : false)
             }
        ]

        response_data << {
          id: user_id,
          name: "#{enrolled_students[user_id]}",
          analysis: user_results.map { |k, v| {id: k, value: v} },
        }
      }

      return {
               data: {
                 scorms: course_modules_details,
                 users: response_data,
               },
             }
    end
  end
end
