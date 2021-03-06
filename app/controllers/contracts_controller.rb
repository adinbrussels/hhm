class ContractsController < ApplicationController
  before_action :set_contract, only: [:show, :edit, :update, :destroy]

  # GET /contracts
  # GET /contracts.json
  def index
    @flat = Flat.find(params[:flat_id])
    @contracts = Contract.all
  end

  # GET /contracts/1
  # GET /contracts/1.json
  def show
    # @flat = Flat.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "file_name",
               :template => "contracts/show.pdf.erb",
               :layout => "pdf.html.erb"
      end
    end

  end

  def pick_renter
    @flats = Flat.all.where(owner_id: current_owner.id)
  end


  def history
   @flat = Flat.find(params[:flat_id])
   @contracts = Contract.where(flat_id: @flat.id)
 end


  # GET /contracts/new
  def new
    @flats = Flat.all.where(owner_id: current_owner.id)
    @flat = Flat.find(params[:flat_id])
    @contract = Contract.new
  end

  # GET /contracts/1/edit
  def edit
    @flat = Flat.find(params[:flat_id])
    @contract = Contract.find(params[:id])
  end



  # POST /contracts
  # POST /contracts.json
  def create

    @contract = Contract.new(contract_params)
    @flat = Flat.find(params[:flat_id])
    @contract.flat_id = @flat.id

    respond_to do |format|
      if @contract.save
        format.html { redirect_to @flat, notice: 'Contract was successfully created.' }
        format.json { render :show, status: :created, location: @contract }

        rent_period = (@contract.rent_end.month - @contract.rent_start.month) + (@contract.rent_end.year - @contract.rent_start.year) * 12

        contract_rent_month = @contract.rent_start.to_date

        rent_period.times do
          Revenue.create(rent_month: contract_rent_month, contract_id: @contract.id, paid: false)
          contract_rent_month = contract_rent_month.next_month
        end

      else
        format.html { render :new }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end

  end


  # PATCH/PUT /contracts/1
  # PATCH/PUT /contracts/1.json
  def update

    respond_to do |format|
      if @contract.update(contract_params)
        format.html { redirect_to flat_contract_path(@contract.flat_id, @contract.id), notice: 'Contract was successfully updated.' }
        format.json { render :show, status: :ok, location: @contract }
      else
        format.html { render :edit }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contracts/1
  # DELETE /contracts/1.json
  def destroy
    @flat = Flat.unscoped.find(params[:flat_id])
    @contract.destroy
    respond_to do |format|
      format.html { redirect_to @flat, notice: 'Contract was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contract
      @contract = Contract.unscoped.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contract_params
      params.require(:contract).permit(:rent_start, :rent_end, :renter_id, :rent_amount, :warranty_amount, :pay_day, :active, :days_to_reminder, :provision)
    end
  end
