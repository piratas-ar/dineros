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
    @dinero.moneda   = params[:dinero][:moneda]
    @dinero.tipo     = 'ingreso'

    if cantidad > 0
      if @dinero.save
        deliver :dineros, :movimiento, [@dinero], url_para_desconfirmar(@dinero)

        redirect '/'
      else
        'Hubo un error al grabar los datos'
      end
    else
      'La cantidad debe ser un número positivo'
    end
  end

  get :desconfirmar, with: :id do
    @dineros = Dinero.where(codigo: params[:id])

    render 'dinero/desconfirmar'
  end

  # Destruye todos los dineros con el mismo código
  post :desconfirmar do
    if params[:dinero][:codigo]
      Dinero.where(codigo: params[:dinero][:codigo]).destroy_all
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
    @dinero.moneda   = params[:dinero][:moneda]
    @dinero.tipo     = 'egreso'

    if cantidad > 0
      if @dinero.save
        deliver :dineros, :movimiento, [@dinero], url_para_desconfirmar(@dinero)
        redirect '/'
      else
        'Hubo un error'
      end
    else
      'La cantidad debe ser un número positivo'
    end
  end

  # La transferencia genera dos movimientos, uno negativo y otro
  # positivo, lo único que cambia en el tesoro es el cambio de manos.
  post :transferir do
    params[:dinero]['cantidad'] = (params[:dinero][:cantidad].to_f * 100).to_i
    halt 'La cantidad debe ser un número positivo' unless params[:dinero][:cantidad] > 0

    recibe  = params[:dinero]
    recibe['tipo'] = 'transferencia'
    entrega = recibe.dup
    entrega['responsable'] = entrega.delete('responsable_entrega')
    recibe['responsable']  = recibe.delete('responsable_recibe')
    entrega['cantidad']    = entrega[:cantidad] * -1

    recibe.delete('responsable_entrega')
    entrega.delete('responsable_recibe')

    dineros = [ Dinero.new(entrega), Dinero.new(recibe) ]

    dineros.first.comentario = "#{dineros.first.nombre} >> #{dineros.last.nombre}: #{dineros.first.comentario}"
    dineros.last.comentario  = dineros.first.comentario

    # Los dos movimientos comparten el mismo codigo
    dineros.last.codigo = dineros.first.asignar_y_devolver_codigo!

    saved = []
    Dinero.transaction do
      saved = dineros.map(&:save)
      raise ActiveRecord::Rollback unless saved.all?
    end

    if saved.all?
      deliver :dineros, :movimiento, dineros, url_para_desconfirmar(dineros.first)

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
    params[:dinero]['cantidad'] = (params[:dinero][:cantidad].to_f * 100).to_i
    params[:dinero]['cantidad_recibida'] = (params[:dinero][:cantidad_recibida].to_f * 100).to_i

    recibido             = params[:dinero]
    recibido['tipo']     = 'intercambio'
    responsable_opcional = recibido.delete('responsable_opcional')
    intercambio_interno  = !responsable_opcional.empty? && (recibido[:responsable] != responsable_opcional)
    entregado            = recibido.dup

    entregado.delete('cantidad_recibida')
    entregado.delete('moneda_recibida')
    entregado['cantidad'] = entregado[:cantidad] * -1
    recibido['cantidad']  = recibido.delete('cantidad_recibida')
    recibido['moneda']    = recibido.delete('moneda_recibida')

    dineros = [ Dinero.new(entregado), Dinero.new(recibido) ]

    # Se hizo un intercambio dentro del sistema.  Si doy 100 ARS a
    # cambio de 1 BTC, hay que registrar:
    #
    # * yo: -100 ARS  -- dinero
    # * vos: -1 BTC   -- dinero_inverso
    # * yo: 1 BTC     -- recibido
    # * vos: 100 ARS  -- recibido_inverso
    if intercambio_interno
      entregado_inverso = recibido.dup
      recibido_inverso  = entregado.dup

      entregado_inverso['cantidad']    = recibido[:cantidad] * -1
      entregado_inverso['responsable'] = responsable_opcional

      recibido_inverso['cantidad']    = entregado[:cantidad] * -1
      recibido_inverso['responsable'] = responsable_opcional

      dineros << Dinero.new(entregado_inverso)
      dineros << Dinero.new(recibido_inverso)
    end

    codigo = dineros.first.asignar_y_devolver_codigo!
    dineros.map do |d|
      d.codigo = codigo
    end

    saved = []
    Dinero.transaction do
      saved = dineros.map(&:save)

      raise ActiveRecord::Rollback unless saved.all?
    end

    if saved.all?
      deliver :dineros, :movimiento, dineros, url_para_desconfirmar(dineros.first)

      redirect '/'
    else
      'No se pudieron guardar los intercambios'
    end
  end
end
