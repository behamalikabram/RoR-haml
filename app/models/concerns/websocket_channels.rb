module WebsocketChannels
  extend ActiveSupport::Concern


  def all_channels
    []
  end
  
  EVENT_CALLBACKS = {}
  
  def trigger_event(event, channel=:all, json=nil)
    json ||= to_json
    
    if callback = self.class::EVENT_CALLBACKS[event.to_sym]
      send callback
    end

    if channel == :all
      all_channels.each do |c| 
        c.trigger(event, json)
      end
    else 
      channel.trigger(event, json)
    end
  end
end