local reader = require 'meownatica:tools/read_toml'

local findinstruct = {}

function findinstruct.find(start_format, goal_format)
    local instruction_start = nil
    local instruction_goal = nil
    local path_instructions = nil
    local instruction_count = reader.ci_len()
    local i = 1
    while (start_format ~= instruction_start or instruction_goal ~= goal_format) and i <= instruction_count do
        path_instructions = reader.ci_get(i)
        instruction_start, instruction_goal = path_instructions:match("(.-)_([^_]+)%.lua")
        instruction_goal = '.' .. instruction_goal
        i = i + 1
    end
    if (start_format == instruction_start) and (instruction_goal == goal_format) then
        return path_instructions
    else
        return nil
    end
end

function findinstruct.convert(path_to_convert, path_instructions)
    local conv = load_script('meownatica:conversion_instructions/' .. path_instructions)
    return conv.convert(path_to_convert)
end


return findinstruct