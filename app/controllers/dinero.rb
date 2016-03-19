require 'time'
Dineros::App.controllers :dinero do
  get :index do
    redirect '/'
  end

  post :ingresar do
    cantidad = (params[:dinero][:cantidad].to_f * 100).to_i
    @dinero = Dinero.new(params[:dinero])
    # TODO: esto podría ir en la validación del modelo...
    # numero de 2 decimales, se eliminan los decimales sobrantes
    @dinero.cantidad = cantidad
    @dinero.moneda = params[:dinero][:moneda]

    if cantidad > 0
      if @dinero.save
        deliver :dineros, :movimiento, @dinero, url_para_desconfirmar(@dinero)

        redirect '/'
      else
        'Hubo un error al grabar los datos'
      end
    else
      'La cantidad debe ser un número positivo'
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

    redirect '/'
  end

  post :desembolsar do
    cantidad = (params[:dinero][:cantidad].to_f * 100).to_i
    @dinero = Dinero.new(params[:dinero])
    # TODO: esto podría ir en la validación del modelo...
    # numero de 2 decimales, se eliminan los decimales sobrantes
    # no se redondea
    @dinero.cantidad = cantidad * -1
    @dinero.moneda = params[:dinero][:moneda]

    if cantidad > 0
      if @dinero.save
        deliver :dineros, :movimiento, @dinero
        redirect '/'
      else
        'Hubo un error'
      end
    else
      'La cantidad debe ser un número positivo'
    end
  end

  post :transferir do
    cantidad = (params[:dinero][:cantidad].to_f * 100).to_i
    if cantidad > 0
      @dinero_entrega = Dinero.new
      # TODO: esto podría ir en la validación del modelo...
      # numero de 2 decimales, se eliminan los decimales sobrantes
      # no se redondea
      @dinero_entrega.cantidad = cantidad * -1
      @dinero_entrega.moneda = params[:dinero][:moneda]
      @dinero_entrega.responsable = params[:dinero][:responsable_entrega]

      @dinero_recibe = Dinero.new
      # TODO: esto podría ir en la validación del modelo...
      # numero de 2 decimales, se eliminan los decimales sobrantes
      # no se redondea
      @dinero_recibe.cantidad = cantidad
      @dinero_recibe.moneda = params[:dinero][:moneda]
      @dinero_recibe.responsable = params[:dinero][:responsable_recibe]

      @dinero_entrega.comentario = @dinero_entrega.nombre
                                                  .concat(' >> ')
                                                  .concat(@dinero_recibe.nombre)
                                                  .concat(': ')
                                                  .concat(params[:dinero][:comentario])
      @dinero_recibe.comentario = @dinero_entrega.comentario

      # valida que la persona que transfiere tenga lo que va a transferir
      if @dinero_entrega.save
        if @dinero_recibe.save
          deliver :dineros, :movimiento, @dinero_entrega
          deliver :dineros, :movimiento, @dinero_recibe
          redirect '/'
        else
          @dinero_entrega.delete
          'Hubo un error'
        end
      else
        'Hubo un error'
      end
    else
      'La cantidad debe ser un número positivo'
    end
  end
end
