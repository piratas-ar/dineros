Dineros::App.controllers  do
  get :index, map: '/', provides: [:html,:xml] do
# Obtener todo el historial
    @dineros = Dinero.all.order(created_at: :desc).page(params[:page]).per(params[:limit] || 10)
# Mostrar el total
    @monedas = Dinero.group(:moneda).pluck(:moneda)
    @total = Dinero.sum(:cantidad)
    @totales = []
    @monedas.each do |moneda|
      total = Dinero.where(moneda: moneda).sum(:cantidad)
      @totales << Money.new(total, moneda) unless total == 0
    end
# Obtener un listado de los que tienen plata en este momento
    @quien_los_tiene = Dinero.group(:responsable).group(:moneda).
      select([:responsable, :moneda, 'sum(cantidad) as subtotal']).
      having('subtotal <> 0')

# Convertir los subtotales a monedas
    @quien_los_tiene.collect do |q|
      q.subtotal = Money.new(q.subtotal, q.moneda)
    end

# Incluir funciones para gravatar
# TODO: usar avatars.io para encontrar avatares en otros servicios?
    Haml::Helpers.send(:include, Gravatarify::Helper)

    case content_type
      when :html then render 'dinero/index'
      when :xml then render 'dinero/feed'
    end
  end
end
