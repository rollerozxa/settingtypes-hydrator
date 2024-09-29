local concat = table.concat
local insert = table.insert
local sprintf = string.format
local rep = string.rep

require('util')
require('settingtypes')

local minetest_example_header = [[
#    This file contains a list of all available settings and their default value for minetest.conf

#    By default, all the settings are commented and not functional.
#    Uncomment settings by removing the preceding #.

#    minetest.conf is read by default from:
#    ../minetest.conf
#    ../../minetest.conf
#    Any other path can be chosen by passing the path as a parameter
#    to the program, eg. "minetest.exe --config ../minetest.conf.example".

#    Further documentation:
#    https://wiki.minetest.net/

]]

local group_format_template = [[
# %s = {
#    offset      = %s,
#    scale       = %s,
#    spread      = (%s, %s, %s),
#    seed        = %s,
#    octaves     = %s,
#    persistence = %s,
#    lacunarity  = %s,
#    flags       =%s
# }

]]

local function create_minetest_conf_example(settings)
	local result = { minetest_example_header }
	for _, entry in ipairs(settings) do
		if entry.type == "category" then
			if entry.level == 0 then
				insert(result, "#\n# " .. entry.name .. "\n#\n\n")
			else
				insert(result, rep("#", entry.level))
				insert(result, "# " .. entry.name .. "\n\n")
			end
		else
			local group_format = false
			if entry.noise_params and entry.values then
				if entry.type == "noise_params_2d" or entry.type == "noise_params_3d" then
					group_format = true
				end
			end
			if entry.comment ~= "" then
				for _, comment_line in ipairs(entry.comment:split("\n", true)) do
					if comment_line == "" then
						insert(result, "#\n")
					else
						insert(result, "#    " .. comment_line .. "\n")
					end
				end
			end
			if entry.type == "key" then
				local line = "See https://github.com/minetest/irrlicht/blob/master/include/Keycodes.h"
				insert(result, "#    " .. line .. "\n")
			end
			insert(result, "#    type: " .. entry.type)
			if entry.min then
				insert(result, " min: " .. entry.min)
			end
			if entry.max then
				insert(result, " max: " .. entry.max)
			end
			if entry.values and entry.noise_params == nil then
				insert(result, " values: " .. concat(entry.values, ", "))
			end
			if entry.possible then
				insert(result, " possible values: " .. concat(entry.possible, ", "))
			end
			insert(result, "\n")
			if group_format == true then
				local flags = entry.values[10]
				if flags ~= "" then
					flags = " "..flags
				end
				insert(result, sprintf(group_format_template, entry.name, entry.values[1],
						entry.values[2], entry.values[3], entry.values[4], entry.values[5],
						entry.values[6], entry.values[7], entry.values[8], entry.values[9],
						flags))
			else
				local append
				if entry.default ~= "" then
					append = " " .. entry.default
				end
				insert(result, sprintf("# %s =%s\n\n", entry.name, append or ""))
			end
		end
	end
	return concat(result)
end

local file = assert(io.open("minetest.conf.example", "w"))
file:write(create_minetest_conf_example(settingtypes.parse_config_file(true, false)))
file:close()
