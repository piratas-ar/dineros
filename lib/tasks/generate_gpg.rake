require 'open3'
require 'dotenv'

Dotenv.load '.env'

namespace :gpg do
  desc 'Genera una llave gpg'
  task :generate do
    gpg = ENV['GPG_BIN']
    # Chequea que tengamos gpg1
    sh "#{gpg} --version"

    Open3::popen3 "#{gpg} --gen-key --batch" do |stdin, stdout, stderr|
      stdin.puts 'Key-Type: RSA'
      stdin.puts 'Key-Length: 4096'
      stdin.puts "Name-Real: #{ENV['FQDN']}"
      stdin.puts "Name-Email: dineros@#{ENV['FQDN']}"
      stdin.puts 'Preferences: SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed'
      stdin.puts 'Key-Usage: sign'
      stdin.puts 'Subkey-Type: RSA'
      stdin.puts 'Subkey-Length: 4096'
      stdin.puts 'Subkey-Usage: encrypt'
      stdin.puts "Passphrase: #{ENV['GPG_PASSWORD']}"
      stdin.puts 'Expire-Date: 0'
      stdin.puts 'Keyserver: hkp://localhost'
      stdin.puts '%commit'
      stdin.close

      STDERR.print stderr.read
    end

    sh "#{gpg} --armor --export dineros@#{ENV['FQDN']} >public/dineros.asc"
  end
end
