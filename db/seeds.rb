[User].each do |klass|
  klass.destroy_all
end

User.create(name: "Adam Hyde", password: "password", password_confirmation: "password", email: "adam@coko.foundation")
User.create(name: "Charlie Ablett", password: "password", password_confirmation: "password", email: "charlie@enspiral.com")
User.create(name: "Jure Triglav", password: "password", password_confirmation: "password", email: "juretriglav@gmail.com")