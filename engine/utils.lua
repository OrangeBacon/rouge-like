function string.endsWith(String, End)
	return End=='' or string.sub(String, -string.len(End))==End
end