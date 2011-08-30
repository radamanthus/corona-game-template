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
  code_dir = "#{app_dir}/#{appname}"
  assets_dir = "#{app_dir}/assets"
  doc_dir = "#{app_dir}/doc"

  # create the app directories
  FileUtils.mkdir_p app_dir
  FileUtils.mkdir_p code_dir
  FileUtils.mkdir_p assets_dir
  FileUtils.mkdir_p doc_dir
  
  # copy the files to the app code directory
  FileUtils.cp_r './.', code_dir

  # copy README
  FileUtils.cp_r 'README', app_dir

  # Remove support files used only for corona-game-template development
  FileUtils.rm_r "#{code_dir}/.git"
  FileUtils.rm_r "#{code_dir}/README"
  FileUtils.rm "#{code_dir}/newgame.rb"
end

def show_help
  print %{
    Creates a new game at the parent directory.
    Usage:
      macruby newgame.rb <appname>
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
