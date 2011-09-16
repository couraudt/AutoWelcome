#author: sweetdub.com

require 'twitter'
require 'sqlite3'
require 'yaml'

class AutoWelcome
  def initialize
    raise "Could'nt load config. Please create a config.yml file in root application directory." if !File.exists?(File.dirname(__FILE__) + '/config.yml')
    yml = YAML::load(File.open(File.dirname(__FILE__) + '/config.yml'))

    raise "Require the message to be send (WELCOME_MSG)." if !yml['WELCOME_MSG']
    raise "Twitter message is too long (maximum is 140 characters)." if yml['WELCOME_MSG'].length > 140
    raise "Twitter message is too short (minimun is 1 character)." if yml['WELCOME_MSG'].length <= 0

    @msg = yml['WELCOME_MSG']

    # Create database file if not exists
    @db = SQLite3::Database.new "autowelcome.db"
    @db.results_as_hash = true
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS followers (
        id INT PRIMARY KEY,
        name VARCHAR(20),
        sended INT DEFAULT 0
      );
    SQL

    # Verify twitter access, and exit if errors
    begin
      @tw = Twitter::Client.new(:consumer_key => yml['CONSUMER_KEY'],
                                :consumer_secret => yml['CONSUMER_SECRET'],
                                :oauth_token => yml['OAUTH_TOKEN'],
                                :oauth_token_secret => yml['OAUTH_TOKEN_SECRET'])
      @tw.verify_credentials
    rescue Twitter::Unauthorized, Twitter::BadRequest => e
      raise "Twitter connection problem: #{e.inspect}"
    rescue => e
      raise "Error: #{e.inspect}"
    end
  end

  # Parse all user's followers and add it to db if not exists
  def populate
    @tw.followers.users.each do |f|
      count = @db.get_first_value("SELECT COUNT(*) FROM followers WHERE id = ?", f.id)
      if count == 0
        @db.execute("INSERT INTO followers (id, name) VALUES (?, ?)", f.id, f.name)
      end
    end
  end

  # Send welcome message to new followers only, and inform if errors
  def send_welcome_msg
    @db.execute("SELECT id, name FROM followers WHERE sended = ?", 0) do |u|
      puts "Send a welcome message to #{u['name']}(#{u['id']})."
      begin
        @tw.direct_message_create(u['id'], @msg)
        @db.execute("UPDATE followers SET sended = ? WHERE id = ?", 1, u['id'])
      rescue Twitter::Unauthorized, Twitter::BadRequest => e
        puts "Twitter connection problem: #{e.inspect}"
      rescue => e
        puts "Error: #{e.inspect}"
      end
    end
  end

  # Loop until exit, call populate and send_welcome_msg each and every 10 scd
  def live
    puts "Press CTRL+C to stop the program."
    Signal.trap("INT") { puts "Exiting..."; exit } # Catch SIG INT to exit properly
    loop do
      self.populate
      self.send_welcome_msg
      sleep 10
    end
  end
end
