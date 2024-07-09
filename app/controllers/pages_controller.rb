class PagesController < ApplicationController
  helper PagesHelper

  def home
    @current_month = params[:month] ? Date.strptime(params[:month], "%Y-%m") : Time.current.beginning_of_month
    @expiring_vaccinations = expiring_vaccinations(@current_month)
    @missing_mandatory_vaccinations = missing_mandatory_vaccinations

    respond_to do |format|
      format.html
      format.json do
        render json: {
          html: render_to_string(partial: 'vaccination_list', locals: { expiring_vaccinations: @expiring_vaccinations, missing_mandatory_vaccinations: @missing_mandatory_vaccinations, displayed_vaccines: {} }, formats: [:html])
        }
      end
    end
  end

  private

  def expiring_vaccinations(date)
    start_date = date.beginning_of_month
    end_date = date.end_of_month

    Vaccination.joins(:vaccine)
               .where("vaccinations.vaccination_date + INTERVAL '1 day' * vaccines.expiry_date BETWEEN ? AND ?", start_date, end_date)
  end

  def missing_mandatory_vaccinations
    Personal.includes(:vaccinations).select do |personal|
      Vaccine.where(mandatory: true).any? do |vaccine|
        !personal.vaccinations.exists?(vaccine_id: vaccine.id)
      end
    end
  end
end
