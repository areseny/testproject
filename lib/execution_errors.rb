module ExecutionErrors

  class NoFileSuppliedError < StandardError; end
  class NoStepsError < StandardError; end
  class NotAuthorisedError < StandardError; end

  class StepNotInstalledError < StandardError
    attr_accessor :missing_step_classes
  end

end