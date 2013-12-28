require 'sinatra'
require 'sinatra/partial'
require 'oauth2'
require 'json'
require 'haml'
require 'yaml'
require 'maruku'

# Routes
get '/' do
  @page_title = "Indexical"
  haml :home
end

# Events routing

get '/events' do
  @page_title = "Transient Series: Upcoming Events"
  @future_events = get_events :order => :ascending, :relative => :future
  haml :events
end

get '/events/past' do
  @page_title = "Transient Series: Past Events"
  @past_events = get_events :order => :descending, :relative => :past
  haml :past
end

get '/events?/:slug' do
  @events = get_events :type => :hash
  if @events.has_key? params[:slug]
    event = @events[params[:slug]]
    locals = {:event => event}
    if event[:meta]["time"] < Date.today
      locals[:past] = true
    end
    @page_title = "Transient Series | #{event[:meta]["title"]}"
    haml :event, :locals => locals
  else
    event = nil
    haml :no_event, :locals => {:event => event}
  end
end

# Releases routing

get '/releases' do
  @page_title = "Indexical Releases"
  # get_releases should by default return all releases in ascending order
  @releases = get_releases :order => :descending
  haml :releases
end

get '/releases?/:slug' do
  @releases = get_releases :type => :hash
  if @releases.has_key? params[:slug]
    release = @releases[params[:slug]]
    locals = {:release => release}
    @page_title = "Indexical Releases | #{release[:meta]["title"]}"
    haml :release, :locals => locals
  else
    release = nil
    haml :no_release
  end
end

# About routing

get '/about' do
  @page_title = "About"
  haml :about
end

not_found do
  haml :'404'
end

#################################################
# Helper methods for retrieving lists of things #
#################################################

##
# Navigation menu list

def get_nav
  active = request.path_info
  nav = JSON.parse File.read('./data/nav.json')
  nav.each do |title, meta|
    ((active != "/") && (meta["href"] == "/")) ? next : false
    if active.match /^#{meta["href"]}?/
      if nav[title].has_key? "class"
        nav[title]["class"] << "active"
      else
        nav[title]["class"] = ["active"]
      end
    end
  end
  nav
end

##
# Event list

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

##
# Releases list

def get_releases opts = {}
  order = opts[:order]        || :ascending
  type = opts[:type]          || :array
  releases = {}
  Dir.glob('./data/releases/*') do |file|
    release = parse_release file
    releases[release[:meta]["slug"]] = release
  end
  
  # Handle the sorting
  releases = case order
  when :descending
    releases.sort_by {|k, v| v[:meta]["time"]}.reverse
  when :ascending
    releases.sort_by {|k, v| v[:meta]["time"]}
  end
  
  # Return either Hash or Array
  case type
  when :hash
    releases_hash = {}
    releases.each {|e| releases_hash[e[0]] = e[1]}
    releases_hash
  when :array
    releases
  end
end

##
# Pull the YAML metadata out of the markdown document

def parse_event file
  lines = File.readlines(file, "\n\n")
  meta = YAML.load lines[0]
  meta["time"] = DateTime.parse(meta["time"])
  meta["slug"] = File.basename file, ".md"
  body = lines[1...lines.length].join("\n\n")
  if meta["image"] && File.exists?("./public/img/events/" + meta["image"])
    meta["image url"] = "/img/events/" + meta["image"]
  end
  {:meta => meta, :body => body}
end

def parse_release file
  lines = File.readlines(file, "\n\n")
  meta = YAML.load lines[0]
  meta["time"] = DateTime.parse(meta["time"])
  meta["slug"] = File.basename file, ".md"
  body = lines[1...lines.length].join("\n\n")
  if meta["image"] && File.exists?("./public/img/releases/" + meta["image"])
    meta["image url"] = "/img/releases/" + meta["image"]
  end
  {:meta => meta, :body => body}
end

def render_tracklist tracklist
  output_string = "<table class=\"table no-border\">"
  tracklist.each do |track|
    output_string << "<tr><td><strong>" << track["composer"] << "</strong></td>"
    if track["title"].respond_to? :join
      output_string << "<td><em>" << track["title"].join("<br />") << "</em></td>"
    else
      output_string << "<td><em>" << track["title"] << "</em></td>"
    end
    output_string << "</tr>"
  end
  output_string << "</table>"
end
