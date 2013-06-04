class Dinero
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :cantidad, Float, :required => true
  property :responsable, String, :required => true, :format => :email_address
  property :comentario, Text
end
