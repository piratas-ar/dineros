require 'pry'
Dineros::App.controllers  do
  get :index, :map => '/' do
    @dineros = Dinero.all

# Se convierten a centavos...
#   @total = Money.new(0, "ARS")
#   @dineros.each do |dinero|
#     @total = @total + Money.new(dinero.cantidad, "ARS")
#   end
    @total = 0
    @dineros.each do |dinero|
      @total = @total + dinero.cantidad
    end

    Haml::Helpers.send(:include, Gravatarify::Helper)

    render 'dinero/index'
  end
end
