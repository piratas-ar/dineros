require 'time'
Dineros::App.controllers :dinero do

  get :index do
    @total = Dinero.sum(:cantidad)

    render 'dinero/index'
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
      redirect '/'
    else
      'Hubo un error'
    end
  end

end
