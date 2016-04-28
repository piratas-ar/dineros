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
    params[:dinero][:cantidad] = (params[:dinero][:cantidad].to_f * 100).to_i
    halt 'La cantidad debe ser un número positivo' unless params[:dinero][:cantidad] > 0

    recibe  = params[:dinero]
    entrega = recibe.dup
    entrega[:responsable] = entrega.delete("responsable_entrega")
    recibe[:responsable]  = recibe.delete("responsable_recibe")
    entrega[:cantidad]    = entrega[:cantidad] * -1

    recibe.delete("responsable_entrega")
    entrega.delete("responsable_recibe")

    dineros = [ Dinero.new(entrega), Dinero.new(recibe) ]

    dineros.first.comentario = "#{dineros.first.nombre} >> #{dineros.last.nombre}: #{dineros.first.comentario}"
    dineros.last.comentario  = dineros.first.comentario

    saved = []
    Dinero.transaction do
      saved = dineros.map(&:save)
    end

    if saved.all?
      dineros.each do |dinero|
        deliver :dineros, :movimiento, dinero
      end

      redirect '/'
    else
      'No se pudieron guardar las transferencias'
    end
  end

  # En los intercambios, pueden pasar dos cosas:
  #
  # * Se intercambió algo entre dos piratas.  Esto quiere decir que
  # habiendo dineros dentro del tesoro, solo cambió de manos, por lo que
  # se registra dos movimientos por pirata, de salida de lo que tenían y
  # de entrada de lo que recibieron de la otra.
  #
  # * Una pirata intercambió algo fuera del tesoro (una venta bah).
  # Habiendo algo en el tesoro, la pirata lo entregó a cambio de otra
  # cosa.  En este caso se registra un movimiento de salida de lo que la
  # pirata tenía y uno de entrada.
  post :intercambiar do
    dineros = []
    dineros << dinero  = Dinero.new
    dinero.cantidad    = (params[:dinero][:cantidad].to_f * 100).to_i * -1
    dinero.moneda      = params[:dinero][:moneda]
    dinero.responsable = params[:dinero][:responsable]
    dinero.comentario  = params[:dinero][:comentario]

    dineros << recibido  = Dinero.new
    recibido.cantidad    = (params[:dinero][:cantidad_recibida].to_f * 100).to_i
    recibido.moneda      = params[:dinero][:moneda_recibida]
    recibido.responsable = params[:dinero][:responsable]
    recibido.comentario  = params[:dinero][:comentario]

    # Se hizo un intercambio dentro del sistema.  Si doy 100 ARS a
    # cambio de 1 BTC, hay que registrar:
    #
    # * yo: -100 ARS  -- dinero
    # * vos: -1 BTC   -- dinero_inverso
    # * yo: 1 BTC     -- recibido
    # * vos: 100 ARS  -- recibido_inverso
    if !params[:dinero][:responsable_opcional].empty?
      dineros << dinero_inverso  = recibido.dup
      dinero_inverso.cantidad    = dinero_inverso.cantidad * -1
      dinero_inverso.responsable = params[:dinero][:responsable_opcional]

      dineros << recibido_inverso  = dinero.dup
      recibido_inverso.cantidad    = recibido_inverso.cantidad * -1
      recibido_inverso.responsable = params[:dinero][:responsable_opcional]
    end

    saved = []
    Dinero.transaction do
      saved = dineros.map(&:save)
    end

    if saved.all?
      dineros.each do |dinero|
        deliver :dineros, :movimiento, dinero
      end

      redirect '/'
    else
      'No se pudieron guardar los intercambios'
    end
  end
end
