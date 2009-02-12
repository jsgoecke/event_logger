#Set our database connection
initialization do
  case COMPONENTS.event_logger[:database_type]
  when "ACTIVERECORD"
    #Initialize the ActiveRecord database
    require 'active_record'
    require File.expand_path(File.dirname(__FILE__) + "/db/models/activerecord/asterisk_event.rb")
    require File.expand_path(File.dirname(__FILE__) + "/db/models/activerecord/call_event.rb")
  when "COUCHDB"
    #Initialize the CouchDB database
    require 'couchrest'
    ::COUCHDB = CouchRest.database!(COMPONENTS.event_logger[:couchdb_url])
  end
end

methods_for :events do
  #Method that may be used in the dialplan to log an event
  def log_event(event)
    
    case COMPONENTS.event_logger[:database_type]
    when "ACTIVERECORD"
      #Create the appropriate database record based on the event class
      if COMPONENTS.event_logger[:event_members][:call_events].include?(event.name)
        event_record = CallEvent.new
      elsif COMPONENTS.event_logger[:event_members][:asterisk_events].include?(event.name)
        event_record = AsteriskEvent.new
      else
        #If we do not recognize the event simply report to the log and move on,
        #not inserting a record in the database
        ahn_log.event_logger.debug "*"*25
        ahn_log.event_logger.debug "Unrecognized event - not inserted" 
        ahn_log.event_logger.debug event.inspect
        ahn_log.event_logger.debug "*"*25
        return
      end
    
      event_record.name = event.name
      event.headers.each do |header|
        #If the field has more than one ':' the header is not being parsed properly
        #this fixes that by spotting it and then parsing it properly
        if header[0].split(' ').length > 1
          header = fix_event_parsing(header)
        end
        event_record.attributes = { header[0].downcase => header[1] }
      end
      event_record.save
      
    when "COUCHDB"
      event_to_log = Hash.new
      event.headers.each do |header|
        #If the field has more than one ':' the header is not being parsed properly
        #this fixes that by spotting it and then parsing it properly
        if header[0].split(' ').length > 1
          header = fix_event_parsing(header)
        end
        event_to_log.merge!({ header[0].downcase => header[1] })
      end
      event_to_log.merge!({ :event_name => event.name.downcase })
      ::COUCHDB.save(event_to_log)
    end
    
  end
  
  #This is a method that is a temporary fix for this known issue:
  #http://adhearsion.lighthouseapp.com/projects/5871/tickets/45-channel-improperly-parsed-in-events
  #once resolved this method will no longer be necessary
  def fix_event_parsing(header)
    first_field = header[0].split(' ')
    header[0] = first_field[0].gsub!(':','')
    header[1] = first_field[1] + ":" + header[1]
    return header
  end
  
end