class PersonalsController < ApplicationController
  before_action :set_personal, only: %i[ show edit update destroy ]

  # GET /personals or /personals.json
  def index
    @personals = Personal.order(created_at: :desc).page(params[:page]).per(30) 
    @button_status = 'info'
  end

  # GET /personals/1 or /personals/1.json
  def show
    @button_status = 'edit'
    @vaccinations = @personal.vaccinations.page(params[:page]).per(10)
  end

  # GET /personals/new
  def new
    @personal = Personal.new
  end

  # GET /personals/1/edit
  def edit
  end

  # POST /personals or /personals.json
  def create
    @personal = Personal.new(personal_params)

    respond_to do |format|
      if @personal.save
        format.html { redirect_to personal_url(@personal), notice: "Personal was successfully created." }
        format.json { render :show, status: :created, location: @personal }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @personal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /personals/1 or /personals/1.json
  def update
    respond_to do |format|
      if @personal.update(personal_params)
        format.html { redirect_to personal_url(@personal), notice: "Personal was successfully updated." }
        format.json { render :show, status: :ok, location: @personal }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @personal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /personals/1 or /personals/1.json
  def destroy
    @personal.destroy

    respond_to do |format|
      format.html { redirect_to personals_url, notice: "Personal was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_personal
      @personal = Personal.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def personal_params
      params.require(:personal).permit(:fio, :date_of_birthday, :gender, :email, :phone_number, :departament)
    end
end
