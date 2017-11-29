module ExecutionErrors

  class NoFileSuppliedError < StandardError; end
  class NoStepsError < StandardError; end
  class NotAuthorisedError < StandardError; end
  class EmptyChainError < StandardError; end

  class StepNotInstalledError < StandardError
    attr_accessor :missing_step_classes
  end

  class ClassNotDefinedError < RuntimeError; end
  class ClassInvalidError < RuntimeError
    attr_accessor :errors, :output
  end

end