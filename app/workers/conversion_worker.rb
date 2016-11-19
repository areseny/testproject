class ConversionWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(chain_id)
    process_chain = ProcessChain.find(chain_id)
    runner = Execution::RecipeExecutionRunner.new(process_chain.step_classes)
    runner.run!(files: process_chain.input_file)
    process_chain.map_results(runner, process_chain.process_steps.sort_by(&:position))
    process_chain.update_attribute(:finished_at, Time.now)
  end
end