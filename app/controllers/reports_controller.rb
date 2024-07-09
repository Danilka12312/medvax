class ReportsController < ApplicationController
  def index
    # Страница выбора отчета
  end

  def generate_vaccine_order_report
    @current_month = Date.today.beginning_of_month
    @vaccine_counts = calculate_vaccine_counts(@current_month)

    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new
        font_path = Rails.root.join("app/assets/fonts/NotoSans-Regular.ttf")
        pdf.font_families.update("NotoSans" => { normal: font_path.to_s })
        pdf.font "NotoSans"

        pdf.text "Количество необходимых вакцин на #{Date.today.beginning_of_month.strftime('%m.%y')}", size: 20
        pdf.move_down 20

        @vaccine_counts.each do |vaccine_name, count| 
          pdf.text "#{vaccine_name} -- #{count} шт.", size: 14
          pdf.move_down 10
        end

        send_data pdf.render, filename: "vaccine_order_report.pdf", type: "application/pdf"
      end
    end
  end

  def generate_employee_vaccine_report
    @current_month = Date.today.beginning_of_month
    @schedules = VaccinationSchedule.includes(:personal, :vaccine)
                                    .where(vaccination_date: @current_month.beginning_of_month..@current_month.end_of_month)
                                    .order('personals.departament, vaccination_schedules.vaccination_date')

    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new(page_layout: :portrait) # Установка макета страницы на портретный режим
        font_path = Rails.root.join("app/assets/fonts/NotoSans-Regular.ttf")
        pdf.font_families.update("NotoSans" => { normal: font_path.to_s })
        pdf.font "NotoSans"

        pdf.text "Отчет о вакцинациях для сотрудников", size: 20
        pdf.move_down 20

        departments = Personal.pluck(:departament).uniq.compact

        departments.each_with_index do |department, index|
          if index > 0
            pdf.start_new_page # Начать новую страницу для каждого нового отдела, кроме первого
          end

          pdf.text "Отдел: #{department}", size: 16
          pdf.move_down 10

          schedules_for_department = @schedules.select { |schedule| schedule.personal.departament == department }

          schedules_for_department.each do |schedule|
            pdf.text "Сотрудник: #{schedule.personal.fio}"
            pdf.text "Вакцина: #{schedule.vaccine.name}"
            pdf.text "Дата: #{schedule.vaccination_date.strftime('%d-%m-%Y')}"
            pdf.text "Время: #{schedule.vaccination_time.strftime('%H:%M')}"
            pdf.text schedule.room.name
            pdf.move_down 15
          end
          pdf.move_down 10
        end

        send_data pdf.render, filename: "employee_vaccine_report.pdf", type: "application/pdf"
      end
    end
end

  private

  def calculate_vaccine_counts(month)
    vaccine_counts = Hash.new(0)
    scheduled_vaccinations = VaccinationSchedule.where(vaccination_date: month.beginning_of_month..month.end_of_month)

    scheduled_vaccinations.each do |schedule|
      vaccine_counts[schedule.vaccine.name] += 1
    end

    vaccine_counts
  end


end
