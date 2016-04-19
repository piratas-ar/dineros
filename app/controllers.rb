Dineros::App.controllers  do
  get :index, map: '/' do
# Obtener todo el historial
    @dineros = Dinero.all.order(created_at: :desc).page(params[:page]).per(params[:limit] || 10)
# Mostrar el total
    @total = Dinero.sum(:cantidad)

    # Obtener una tabla así:
    #
    # | Moneda | Responsable | Ingreso | Egreso | Balance |
    # +--------+-------------+---------+--------+---------+
    # | ARS    | fauno       | 3000    | 300    | 2700    |
    # | BTC    | fauno       |    1    |   0    |    1    |
    @balances = Dinero.group(:moneda).group(:responsable).
      select([ :grupo, :responsable, :moneda,
      'sum(case when cantidad > 0 then cantidad else 0 end) as ingreso',
      'sum(case when cantidad < 0 then cantidad else 0 end) as egreso',
      'sum(cantidad) as cantidad' ])

    @balances_resumen = Dinero.group(:moneda).
      select([ :responsable, :moneda,
      'sum(case when cantidad > 0 then cantidad else 0 end) as ingreso',
      'sum(case when cantidad < 0 then cantidad else 0 end) as egreso',
      'sum(cantidad) as cantidad' ])

    @balance_grupal = PivotTable::Grid.new do |g|
      g.source_data = Dinero.group(:grupo).group(:moneda)
        .select([ :grupo, :moneda, 'sum(cantidad) as cantidad' ])

      g.column_name = :moneda
      g.row_name    = :grupo
      g.value_name  = :cantidad
    end
    @balance_grupal.build

# Incluir funciones para gravatar
# TODO: usar avatars.io para encontrar avatares en otros servicios?
    Haml::Helpers.send(:include, Gravatarify::Helper)

    render 'dinero/index'
  end

  get :feed, provides: :xml do
    @dineros = Dinero.all.order(created_at: :desc)
    render 'dinero/feed'
  end
end
