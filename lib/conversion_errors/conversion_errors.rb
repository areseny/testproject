module ConversionErrors

  class ConversionError < StandardError; end
  class NoFileSuppliedError < ConversionError; end
  class NoStepsError < ConversionError; end
  class NotAuthorisedError < ConversionError; end

end