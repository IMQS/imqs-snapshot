require 'seven_zip_ruby'
require 'fileutils'

server_name = 'demo'
snap_location = '\snapper\snapshots\\'
db_location = '\imqsvar\db\data'

snap_location += server_name

if File.directory?(snap_location)
	FileUtils.rm_rf(snap_location)
end
FileUtils.mkdir_p(snap_location)
snap_location += '\\'

File.open(snap_location + 'dbdumps.7z', 'wb') do |file|
	SevenZipRuby::SevenZipWriter.open(file) do |szw|
		szw.add_directory(db_location, as: '.')		
	end
end