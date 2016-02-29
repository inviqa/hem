namespace :ops do
  argument 'domain'
  task 'generate-self-signed-cert' do |task, args|
    cert = Hem::Lib::SelfSignedCertGenerator.generate args[:domain]
    puts "Key:\n#{cert[:key]}\nCert:\n#{cert[:cert]}\n"
  end
end
