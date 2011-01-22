require 'fileutils'

# Creates a new game at the parent directory.
# Usage:
#   macruby newgame <appname>
# For example, if this template is on /Users/rad/Documents/games/corona-game-template,
# running "macruby newgame mygame"
# will create the directory /Users/rad/Documents/games/mygame
# and copy all files from the template to that directory

def generate_new_app(appname)
  app_dir = "../#{appname}"
  # create the app directory
  FileUtils.mkdir_p(app_dir)
  
  # copy the files to the target directory
  FileUtils.cp_r './.', app_dir
  
  # remove the git directory from the target directory
  FileUtils.rm_r "#{app_dir}/.git"
end

def show_help
  print %{
    Creates a new game at the parent directory.
    Usage:
      macruby newgame <appname>
    For example, if this template is on /Users/rad/Documents/games/corona-game-template,
    running "macruby newgame mygame"
    will create the directory /Users/rad/Documents/games/mygame
    and copy all files from the template to that directory    
  }
end

def main
  appname = ARGV[0]
  if appname && appname.strip != ''
    generate_new_app(appname)
  else
    show_help
  end
end

main()