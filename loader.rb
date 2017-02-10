require 'seven_zip_ruby'
require 'fileutils'

server_name = 'demo'
snap_location = '\snapper\snapshots\\'
db_location = '\imqsvar\db\data'

snap_location += server_name + '\\'

FileUtils.rm_rf(db_location)
FileUtils.mkdir_p(db_location)

File.open(snap_location + 'dbdumps.7z', 'rb') do |file|
	SevenZipRuby::Reader.extract_all(file, db_location)
end