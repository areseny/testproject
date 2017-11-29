module ObjectMethods
  def class_from_string(str)
    str.split('::').inject(Object) do |mod, class_name|
      mod.const_get(class_name)
    end
  rescue => e
    ap e.message
    ap e.backtrace
    nil
  end
end