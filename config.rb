# Config for rubybot

puts "Loading config ..."

class RubyBot
  # The passphrase
  # The format of a command to the bot on the mush must
  # follow this:
  # <PASSPHRASE:command:#dbref>args
  # Change PASSPHRASE to something below.
  PASSPHRASE = 'PASSPHRASE'

  # The address of the mush to connect to.
  HOST       = 'localhost'
  PORT       = 4201

  # The connect string
  LOGIN      = 'connect yourbot yourpass'
end

class SQL
  # Connect information for the MySQL database
  HOST = 'localhost'
  USER = 'myuser'
  PASS = 'mypass'
  DB   = 'mydb'
end

class Spell
  # Dictionary name
  DICT = "en_US"
end

class Dictionary
  # dictionary servers
  SERVERS = ['dict.org','alt0.dict.org']
  # SERVERS = ['localhost']
end

class Fortune
  # The fortune executable
  FORTUNE     = '/usr/bin/fortune'
  # The directory where the fortunes are kept
  FORTUNESDIR = '/usr/share/fortune'
end

class Googleplug
  # The file with the key for Google
  KEYFILE = '~/.google_key'
  # Alternately, the key can be set directly.
  # KEY = "..."
end

class Talkfilter
  # Where the talkfilter executables are kept.
  TALKFILTER_PATH ='/usr/bin'
  # The talkfilters.
  TALKFILTERS    = %w{b1ff brooklyn chef cockney drawl fudd funetak
                      jethro jive kraut pansy postmodern valspeak warez}
end
class Units
  # The units executable, with a -q flag for quiet
  UNITS = '/usr/bin/units -q'
end
