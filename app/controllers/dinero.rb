require 'time'
Dineros::App.controllers :dinero do

  get :index do
    redirect_to '/'
  end

  get :cargar do
    @dinero = Dinero.new

    render 'dinero/cargar'
  end

  post :crear do
    @dinero = Dinero.new(params[:dinero])
# TODO esto podría ir en la validación del modelo...
    @dinero.cantidad = (params[:dinero][:cantidad].to_f * 100).to_i

    if @dinero.save
      deliver :dineros, :movimiento, @dinero
      redirect '/'
    else
      'Hubo un error'
    end
  end

  get :desconfirmar, with: :id do
    @dinero = Dinero.find_by(codigo: params[:id])

    render 'dinero/desconfirmar'
  end

  post :desconfirmar do
    if params[:dinero][:codigo]
      @dinero = Dinero.find_by(codigo: params[:dinero][:codigo])
      @dinero.destroy!
    end

    redirect_to '/'
  end
end
