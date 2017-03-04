module EventConstants

  # To trigger:

  # Pusher.trigger('channel', 'event', {foo: 'bar'})
  # Pusher.trigger(['channel_1', 'channel_2'], 'event_name', {foo: 'bar'})

  def trigger_event(channels:, event:, data: {})
    ap "Triggering event #{event} on channels #{channels} with data #{data}"
    ap "Pusher info: app ID: #{Pusher.app_id}, key: #{Pusher.key}, secret: #{Pusher.secret}, host: #{Pusher.host}, port: #{Pusher.port}"
    Pusher.trigger(channels, event, {})
  rescue Pusher::Error => e
    # (Pusher::AuthenticationError, Pusher::HTTPError, or Pusher::Error)
    ap "PUSHER ERROR!"
    ap e.message
    ap e.backtrace
  rescue => e
    ap e.message
    ap e.backtrace
  end

  # recipe channel and events

  def recipe_channel(recipe_id)
    "recipe_#{recipe_id}"
  end

  def recipe_updated_event
    'recipe_updated'
  end

  # process chain channel and events

  def process_chain_channel(process_chain_id)
    "process_chain_#{process_chain_id}"
  end

  def process_chain_error_event
    'processing_error'
  end

  def process_chain_started_processing_event
    'processing_started'
  end

  def process_chain_done_processing_event
    'processing_completed'
  end

  # process step channel and events

  def process_step_channel(process_step_id)
    "process_step_#{process_step_id}"
  end

  def process_step_started_event
    'process_step_started'
  end

  def process_step_finished_event
    'process_step_finished'
  end

end