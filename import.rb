require 'fileutils'
require '.\export.rb'

def import(args)
	server_name = args[0]
	snap_location = '\snapper\snapshots\\'
	db_location = '\imqsvar\postgres'
	conf_location = '\imqsbin\conf'

	if (File.directory?(db_location) && File.directory?(conf_location) && !File.directory?(snap_location + 'backup'))
		puts('Found existing system with no backup. Making backup.')
		export([ 'backup' ])

		p('Importing system')
		FileUtils.rm_rf(db_location)
	end
	if File.directory?(db_location)
		FileUtils.rm_rf(db_location)
	end
	if File.directory?(conf_location)
		FileUtils.rm_rf(conf_location)
	end
	FileUtils.mkdir_p(db_location)
	FileUtils.mkdir_p(conf_location)

	snap_location += server_name + '\\'

	p("Unziping #{server_name} dbdumps")
	cmd = "7z x #{snap_location}dbdumps.7z -o#{db_location}"
	`#{cmd}`

	p("Unziping #{server} confdumps")
	cmd = "7z x #{snap_location}confdumps.7z -o#{conf_location}"
	`#{cmd}`
end

if __FILE__ == $0
	args = ARGV
	if args.length == 0
		puts('Not enough arguments.')
		puts('import.rb <server_name>')
		abort
	end

	if args.length > 1
		puts('To many arguments.')
		puts('import.rb <server_name>')
		abort
	end

	import(args)
end
