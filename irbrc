require "irb/completion"
ARGV << "--readline"

if File.basename($PROGRAM_NAME) =~ /\A(?:irb|restclient|rails)/
  IRB.conf[:PROMPT_MODE] = :SIMPLE

  IRB.conf[:EVAL_HISTORY] = 1000
  IRB.conf[:SAVE_HISTORY] = 100

  HISTFILE = "~/.irb_history"
  MAXHISTSIZE = 100

  if defined? Readline::HISTORY
    histfile = File::expand_path( HISTFILE )
    if File::exists?( histfile )
      lines = IO::readlines( histfile ).collect {|line| line.chomp}
      puts "Read %d saved history commands from %s." %
           [ lines.nitems, histfile ] if $DEBUG || $VERBOSE
      Readline::HISTORY.push( *lines )
    else
      puts "History file '%s' was empty or non-existant." %
           histfile if $DEBUG || $VERBOSE
    end

    Kernel::at_exit {
      lines = Readline::HISTORY.to_a.reverse.uniq.reverse
      lines = lines[ -MAXHISTSIZE, MAXHISTSIZE ] if lines.size > MAXHISTSIZE
      $stderr.puts "Saving %d history lines to %s." %
                   [ lines.size, histfile ] if $VERBOSE || $DEBUG
      File::open( histfile, File::WRONLY|File::CREAT|File::TRUNC ) {|ofh|
        lines.each {|line| ofh.puts line }
      }
    }
  end

  def ri(*names)
    system(%{ri #{names.join(" ")}})
  end
  
  def copy(str)
    open("| pbcopy", "w") { |clipboard| clipboard << str.to_s }
  end
  
  def paste
    `pbpaste`
  end
  
  def clip
    history = Readline::HISTORY.entries
    index   = history.rindex("exit") || -1
    content = history[(index+1)..-2].join("\n")
    puts "Session copied to clipboard."
    copy content
  end
end
