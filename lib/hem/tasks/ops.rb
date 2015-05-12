namespace :ops do
  task 'generate-self-signed-cert', [ 'domain' ] do |task, args|
    cert = Hobo::Lib::SelfSignedCertGenerator.generate args[:domain]
    puts "Key:\n#{cert[:key]}\nCert:\n#{cert[:cert]}\n"
  end
end