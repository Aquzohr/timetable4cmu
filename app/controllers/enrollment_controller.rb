class EnrollmentController < ApplicationController

  def index
  end

  def show

    if validate(params[:sid], params[:term])
      redirect_to root_url, :notice => "Fail Login, make sure your infomation!"
      return
    end

    term = params[:term].split('/')
    semester = term[0]
    year = term[1]
    @sid = params[:sid]

    entrollment = EnrollmentService.new

    @times = Array["0600","0700","0800","0900","1000","1100","1200","1300","1400","1500","1600","1700","1800","1900","2000","2100","2200","2300","2400"]
    @days = Array["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    
    #timetable
    @courses = entrollment.courses(semester, year, @sid)

    if @courses == "error"
      redirect_to root_url, :notice => "Fail Login, Term not found!"
      return
    end

    @classes = course_class(@courses)
    @range = range_time(@courses)
    @course_days = course_day(@courses)

    #mid
    @courses_mid = entrollment.midterm_exam(semester, year, @sid)
    @classes_mid = course_class(@courses_mid)
    @range_mid = range_time(@courses_mid)
    @course_days_mid = course_day(@courses_mid)

    #final
    @courses_final = entrollment.final_exam(semester, year, @sid)
    @classes_final = course_class(@courses_final)
    @range_final = range_time(@courses_final)
    @course_days_final = course_day(@courses_final)

  end


  private
    def validate(sid, term)
      return true if sid.blank? || term.blank?
      return true if sid.include?("_") || term.include?("_")
    end

    def course_day(courses)

      course_days = {}

      courses.each do |course|

        day = course[:day]

        day = "Mo" if day == "M"
        day = "We" if day == "W"
        day = "Fr" if day == "F"

        if course_days.blank?
          course_days[day] = day
        end
        
        if course_days[day].blank?
          course_days[day] = day
        end

      end

      return course_days
  
    end

    def course_class(courses)

      course_classes = Hash.new
      class_index = 1
  
      courses.each do |course|
        
        if course_classes.blank?
          course_classes[course[:no]] = "course#{class_index}"
          class_index += 1
        end
  
        if course_classes[course[:no]].blank?
          course_classes[course[:no]] = "course#{class_index}"
          class_index += 1
        end
  
      end
  
      return course_classes
  
    end
  
    def range_time(courses)
      start_time = "2400"
      end_time = "0000"
  
      courses.each do |course|
  
        if course[:time][:start] < start_time
          start_time = course[:time][:start]
        end
  
        if course[:time][:end] > end_time
          end_time = course[:time][:end]
        end
  
      end
  
      return {
        start_time: start_time,
        end_time: end_time
      }
  
    end
  
end
