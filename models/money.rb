# una version chiquita de Money que acepte muchas monedas
class Money
  attr_reader :currency, :cents

  def initialize(cents, currency)
    @currency = currency
    @cents = cents
  end

  def format
    "#{Money.thousands_separator(cents)} #{currency}"
  end

  def self.thousands_separator(cents, sep = '.', dec_sep = ',')
    int = (cents / 100).to_s.reverse.gsub(/(\d{3})(?=\d)/, "\\1#{sep}").reverse
    dec = (cents / BigDecimal(100)) - (cents / 100)

    if dec == 0.0
      "#{int}"
    else
      "#{int}#{dec_sep}#{(dec * 100).to_i}"
    end
  end
end
