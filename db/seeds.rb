[Account].each do |klass|
  klass.destroy_all
end

Account.create(name: "Charlie Ablett", password: "password", password_confirmation: "password", email: "charlie@enspiral.com")
Account.create(name: "Adam Hyde", password: "password", password_confirmation: "password", email: "adam@coko.foundation")
Account.create(name: "Coko Demo", password: "password", password_confirmation: "password", email: "ink-demo@coko.foundation")