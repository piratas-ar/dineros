class Dinero
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :cantidad, Float
  property :responsable, String, :format => :email_address
  property :comentario, Text
end
