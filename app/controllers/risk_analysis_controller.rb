class RiskAnalysisController < ApplicationController

  def get_risk_analysis
    enrolled_students = Moodle::Api.core_enrol_get_enrolled_users(courseid: params[:courseid], options: [{:name => 'userfields', :value => 'fullname'}])
    course_scorms = Moodle::Api.mod_scorm_get_scorms_by_courses(courseids: Array(params[:courseid].to_i))

    if enrolled_students.blank?
      return {type: :error, message: 'There are 0 enrolled users.'}
    else
      enrolled_students_tmp = {}
      enrolled_students.map{|user|
        enrolled_students_tmp[user['id']] = user['fullname']
      }
      enrolled_students = enrolled_students_tmp
    end

    scoes_tracks = MoodleController.connection.exec_query("
      SELECT ssc.userid, ssc.scormid, ssc.scoid, ssc.attempt, ssc.element, ssc.value
      FROM moodle.mdl_scorm_scoes_track ssc
      WHERE ssc.scoid IN (
          SELECT id FROM moodle.mdl_scorm_scoes WHERE scorm IN (
            SELECT id FROM moodle.mdl_scorm WHERE course = #{params[:courseid]}) AND scormtype = 'sco')
          AND ssc.userid IN (#{enrolled_students.keys.join(',').to_s})
        AND ssc.element = 'cmi.core.lesson_status';")

    if scoes_tracks.blank?
      return {type: :error, message: 'Course does not have scorm data for users'}
    else
      response_data = []

      data = scoes_tracks.group_by{|r| r['userid']}
      course_scoes = scoes_tracks.map{|c| c['scoid']}.uniq

      data.map{|user, d|
        user_analysis = d.group_by{|t| t['scoid']}.map{|k, v| Hash[k, v.map{|e| e.slice('element', 'value')}]}
        result = course_scoes.product([false]).to_h

        user_analysis.each{|sc|
          sc.each{|k,v|
            v.each{|p|
              result[k] = true if p['value'].in? ["complete", "passed"]
            }
          }
        }

        response_data << {
          id: user,
          name: "#{enrolled_students[user]}",
          analysis: result.map{|k, v| {id: k, value: v}}
        }

      }
      
      {
        data: {
          scorms: course_scorms['scorms']
            .map{|scorm| {id: scorm['launch'], title: scorm['name']}},
          users: response_data
        }
      }
    end
  end

  def transform_risk_analysis_data
    {data: JSON.parse(params[:data])}
  end

end