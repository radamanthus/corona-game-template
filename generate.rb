require 'json'

MENU_CODE = %{
  local #<name>Button = display.newImage("images/buttons/#<name>.png")
  local function #<name>Pressed ( event )
  	if event.phase == "ended" then
  		#<change_scene_code>
  	end
  end
  #<name>Button:addEventListener("touch", #<name>Pressed)
  #<name>Button.x = #<x>
  #<name>Button.y = #<y>
  localGroup:insert(#<name>Button)        
  
}

def generate_menu_code_for(menu_item)
  button_transition = menu_item['transition'][0]
  button_transition_options = menu_item['transition'][1..-1]
  if button_transition_options.empty?
    change_scene_code = %{director:changeScene("#{menu_item['name']}", "#{button_transition}")}
  else
    transition_options = button_transition_options.collect do |o| 
      begin 
        Float(o)        
      rescue
        %{"#{o}"}  
      end      
    end.join(',')
    change_scene_code = %{director:changeScene("#{menu_item['name']}", "#{button_transition}", #{transition_options})}
  end
  menu_code = MENU_CODE.clone
  menu_code.gsub!('#<name>', menu_item['name'])
  menu_code.gsub!('#<x>', menu_item['x'].to_s)
  menu_code.gsub!('#<y>', menu_item['y'].to_s)
  menu_code.gsub!('#<change_scene_code>', change_scene_code)  
  menu_code
end

# Load the template
template = DATA.readlines

# Read the menu.txt file
menu_file = File.open('menu.json', 'r')
menu = JSON.parse(menu_file.readlines.join(' '))

# Generate the screen .lua file
menu.each do |screen|
  screen_file = File.new("#{screen['name']}.lua", 'w+')
  template.each do |l|
    screen_file.print l
  end
  screen_file.close
end

# Update menu.lua
# Read the entire file into memory, insert the generated code, then overwrite the existing menu.lua
menu_lua_file = File.open('menu.lua', 'r+')
menu_lua_file_lines = menu_lua_file.readlines
menu_lua_file.close
menu_lua_file = File.open('menu.lua', 'w+')
menu_lua_file_lines.each do |line|
  menu_lua_file.print line
  if line.include?("-- Menu Buttons - Start") # Look for the start markup
    menu.each do |menu_item|
      menu_lua_file.print generate_menu_code_for menu_item
    end
  end    
end
menu_lua_file.close

__END__
module(..., package.seeall)

-- Main function - MUST return a display.newGroup()
function new()
	local localGroup = display.newGroup()
	
	-- Background
	local background = display.newImage("images/backgrounds/default.png")
	localGroup:insert(background)
	
	-- Title
	local title = display.newText("Touch to go back", 0, 0, native.systemFontBold, 16)
	title:setTextColor( 255,255,255)
	title.x = 160
	title.y = 240
	title.name = "title"
	localGroup:insert(title)
	
	-- Touch to go back
	local function touched ( event )
		if event.phase == "ended" then
			director:changeScene("menu","fade")
		end
	end
	background:addEventListener("touch",touched)
	
	unloadMe = function()
	end	
	
	-- MUST return a display.newGroup()
	return localGroup
end
