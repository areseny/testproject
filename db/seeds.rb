[User, StepClass].each do |klass|
  klass.destroy_all
end

User.create(name: "Adam Hyde", password: "password", password_confirmation: "password", email: "adam@coko.foundation")
User.create(name: "Charlie Ablett", password: "password", password_confirmation: "password", email: "charlie@enspiral.com")
User.create(name: "Jure Triglav", password: "password", password_confirmation: "password", email: "juretriglav@gmail.com")

StepClass.create(name: "Step", description: "A test converion that returns the same file you supplied. Useful for testing purposes but not much else.")
StepClass.create(name: "Docx2Html", description: "A comprehensive conversion sing ottoville/docx2html.xsl")
StepClass.create(name: "DocxToHtml", description: "A simpler docx to html conversion")