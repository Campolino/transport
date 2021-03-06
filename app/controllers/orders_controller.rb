class OrdersController < ApplicationController
    before_action :set_order, only: [:show, :edit, :update]

    before_action :authenticate_user!
    before_action :check_admin, only: [:new, :create]
    before_action :check_carrier, only: [:index]
    
    def index
        # mostra pedidos correspondente ao CARRIER_ID do USER
    end

    def show
        @order = Order.find(params[:id])
    end

    def new
        @order = Order.new
        @carriers = Carrier.all
    end

    def create
        @order = Order.new(order_params)

        if @order.save!
            redirect_to @order, notice: 'Ordem criada com sucesso.'
        else
            flash.now[:notice] = 'Não foi possível criar essa ordem de pedido.'
            @carriers = Carrier.all
            render 'new'
        end
    end

    def edit
        @order = Order.find(params[:id])
        @vehicles = Vehicle.where('carrier_id = ?', @order.carrier_id)
    end

    def update
        if @order.update!(order_params)
            redirect_to @order, notice: 'Ordem editada com sucesso.'
        else
            flash.now[:notice] = 'Não foi possível editar a Ordem'
            @vehicles = Vehicle.where('carrier_id = ?', @order.carrier_id)
            render 'edit'
        end
    end

    private

    def set_order
        @order = Order.find(params[:id])
    end

    def order_params
        params.require(:order).permit(:vendor_address, :item_code, :item_dimension, :item_weight, :client_address, :client_information, :carrier_id, :vehicle_id, :update_address, :status)
    end

    def check_admin
        user = current_user
        if current_user.user?
            redirect_to root_path, alert: 'Você não tem permissão para acessar essa página.'
        end
    end

    def check_carrier
        user = current_user
        if user.admin?
            @carriers = Carrier.all
            @orders = Order.all
        else
            @carriers = Carrier.where('id = ?', user.carrier_id)
            @orders = Order.where('carrier_id = ?', user.carrier_id)
            if @carriers.empty?
                redirect_to root_path, notice: 'Não há transportador cadastrada para o seu usuário. Contate o administrador do sistema!'
            end
        end
    end
    
end