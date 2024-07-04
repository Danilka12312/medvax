# app/controllers/vaccinations_controller.rb
class VaccinationsController < ApplicationController
  def create
    @personal = Personal.find(params[:personal_id])
    @vaccination = @personal.vaccinations.build(vaccination_params)

    if @vaccination.save
      redirect_to @personal, notice: 'Вакцинация успешно добавлена.'
    else
      render 'personals/show'
    end
  end

  private

  def vaccination_params
    params.require(:vaccination).permit(:vaccine_id, :vaccination_date)
  end
end
