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
    @dinero.cantidad = (params[:dinero][:cantidad].to_f * 100).to_i
    @dinero.fecha = DateTime.now

    if @dinero.save
      redirect '/'
    else
      'Hubo un error'
    end
  end

end
