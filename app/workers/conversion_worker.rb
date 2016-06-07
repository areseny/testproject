class ConversionWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(chain_id)
    conversion_chain = ConversionChain.find(chain_id)
    runner = Conversion::RecipeExecutionRunner.new(conversion_chain.step_classes)
    runner.run!(conversion_chain.input_file)
    conversion_chain.map_results(runner, conversion_chain.conversion_steps.sort_by(&:position))
    conversion_chain.update_attribute(:finished_at, Time.now)
  end
end