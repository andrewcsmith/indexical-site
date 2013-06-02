require 'sinatra'
require 'oauth2'
require 'json'
require 'haml'
require 'yaml'
require 'maruku'

# Routes
get '/' do
  haml :home
end

get '/events' do
  @future_events = get_events :order => :ascending, :relative => :future
  haml :events
end

get '/events/past' do
  @past_events = get_events :order => :descending, :relative => :past
  haml :past
end

get '/releases' do
  haml :releases
end

get '/event/:slug' do
  @events = get_events :type => :hash
  if @events.has_key? params[:slug]
    @event = @events[params[:slug]]
    haml :event
  else
    @event = nil
    haml :no_event
  end
end

def get_events opts = {}
  order = opts[:order]        || :ascending
  relative = opts[:relative]  || :all
  type = opts[:type]          || :array
  events = {}
  Dir.glob('./data/events/*') do |file|
    event = parse_event file
    events[event[:meta]["slug"]] = event
  end
  
  # Handle the date filter
  events = case relative
  when :future
    events.reject {|k, e| e[:meta]["time"] < Date.today}
  when :past
    events.reject {|k, e| e[:meta]["time"] >= Date.today}
  when :all
    events
  end
  
  # Handle the sorting
  events = case order
  when :descending
    events.sort_by {|k, v| v[:meta]["time"]}.reverse
  when :ascending
    events.sort_by {|k, v| v[:meta]["time"]}
  end
  
  # Return either Hash or Array
  case type
  when :hash
    events_hash = {}
    events.each {|e| events_hash[e[0]] = e[1]}
    events_hash
  when :array
    events
  end
end

def parse_event file
  lines = File.readlines(file, "\n\n")
  meta = YAML.load lines[0]
  meta["time"] = DateTime.parse(meta["time"])
  meta["slug"] = File.basename file, ".md"
  body = lines[1...lines.length].join("\n\n")
  {:meta => meta, :body => body}
end