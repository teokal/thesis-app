class RiskAnalysisController < ApplicationController

  def get_risk_analysis
    scoes_tracks = MoodleController.connection.exec_query("
      SELECT ssc.userid, u.lastname, u.firstname, ssc.scormid, ssc.scoid, ssc.attempt, ssc.element, ssc.value
      FROM  moodle.mdl_scorm_scoes_track ssc
      JOIN moodle.mdl_user u ON ssc.userid = u.id
      WHERE ssc.scoid IN (
        SELECT id FROM moodle.mdl_scorm_scoes WHERE scorm IN (
          SELECT id FROM moodle.mdl_scorm WHERE course = #{params[:courseid] || 13}) AND scormtype = 'sco')
        AND ssc.element = 'cmi.core.lesson_status';")

    if scoes_tracks.blank?
      {type: :error, message: 'Course does not have scorm data for users'}
    else
      data1 = []
  
      data = scoes_tracks.group_by{|r| [r['userid'], r['lastname'], r['firstname']]}
      course_scoes_ids = scoes_tracks.map{|c| c['scoid'].to_s}.uniq
      course_counter = course_scoes_ids.count

      data.map{|user, d|
        user_analysis = d.group_by{|t| t['scoid']}.map{|k, v| Hash[k, v.map{|e| e.slice('element', 'value')}]}
        result = course_scoes_ids.product([0]).to_h
        
        user_analysis.each{|sc|
          sc.each{|k,v| 
            v.each{|p| 
              result[k] = 1 if p['value'].in? ["complete", "passed"]
            }
          }
        }

        result = course_counter > 0 ? (result.values.inject(0){|sum,x| sum + x }*1.0 / course_counter > 0.60 ? true : false) : 0.0
    
        data1 << {
          userid: user[0],
          fullname: "#{user[1]} #{user[2]}",
          # analysis: user_analysis,
          safe: result,
          in_danger: result,
        }
      }
      {data: data1}
    end
  end

end