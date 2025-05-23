local digits = "0123456789"

local function isDigit(char)
	for i = 1, #digits do
		if digits:sub(i, i) == char then return true end
	end

	return false
end

function octalToDecimal(octal)
    local decimal = 0

    local n = #octal - 1
    local i = 1

    while n >= 0 do
        decimal = decimal + ( tonumber(octal:sub(i, i)) * (8 ^ n)  )

        n = n - 1
        i = i + 1
    end

    return decimal
end

return
function(object)
	local dirtyJson = json.tostring(object)

	local wetJson = ""

	local i = 1

	while i <= #dirtyJson do
		local sub = dirtyJson:sub(i, i)

		if sub == '\\' then
			local strCode = ""

			local j = i

			while true do
				j = j + 1

				local codeSub = dirtyJson:sub(j, j)

				if not isDigit(codeSub) then break
				else strCode = strCode..codeSub end
			end

			if #strCode > 1 then
				i = j - 1

				wetJson = wetJson..string.char(octalToDecimal(strCode))
			end
		else wetJson = wetJson..sub end

		i = i + 1
	end

	return wetJson
end