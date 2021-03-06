module EventConstants

  # To trigger:

  # Pusher.trigger('channel', 'event', {foo: 'bar'})
  # Pusher.trigger(['channel_1', 'channel_2'], 'event_name', {foo: 'bar'})

  def trigger_event(channels:, event:, data: {})
    log "Triggering event #{event} on channels #{channels} with data #{data}"
    log "Pusher info: app ID: #{Pusher.app_id}, key: #{Pusher.key}, secret: #{Pusher.secret}, host: #{Pusher.host}, port: #{Pusher.port}"
    Pusher.trigger(channels, event, data)
  rescue Pusher::Error => e
    # (Pusher::AuthenticationError, Pusher::HTTPError, or Pusher::Error)
    log "PUSHER ERROR!"
    log e.message
    log e.backtrace
  rescue => e
    log e.message
    log e.backtrace
  end

  def log(message)
    if self.respond_to?(:log_as_step)
      log_as_step message
    else
      ap message
    end
  end

  # recipe channel and events
  def recipe_channel
    "recipes"
  end

  def recipe_updated_event
    'recipe_updated'
  end

  # process chain channel and events

  def chain_creation_channel(account_id)
    "#{account_id}_process_chain_creation"
  end

  def execution_channel
    "process_chain_execution"
  end

  def process_chain_created_event
    'chain_created'
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

  # process step events

  def process_step_started_event
    'process_step_started'
  end

  def process_step_finished_event
    'process_step_completed'
  end

  # standalone execution events

  def standalone_execution_channel(account_id)
    "#{account_id}_standalone_execution"
  end

  def standalone_execution_started_event(account_id)
    "#{account_id}_standalone_execution_started"
  end

  def standalone_execution_finished_event(account_id)
    "#{account_id}_standalone_execution_completed"
  end

  def standalone_execution_error_event
    'standalone_processing_error'
  end

end