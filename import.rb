require 'fileutils'
require '.\services.rb'
require '.\export.rb'

def import(args)
	server_name = args[0]
	snap_location = '\snapper\snapshots\\'
	db_location = '\imqsvar\postgres'
	bin_location = '\imqsbin\bin'
	conf_location = '\imqsbin\conf'

	if !File.directory?(snap_location + server_name)
		puts("Snapshot #{server_name} not found. Aborting...")
		abort
	end

	if (File.directory?(db_location) && File.directory?(bin_location) && File.directory?(conf_location) && !File.directory?(snap_location + 'backup'))
		puts('Found existing system with no backup. Making backup.')
		export([ 'backup' ])
		puts('Importing snapshot')
	end

	snap_location += server_name + '\\'

	if File.exist?(snap_location + 'dbdumps.7z')
		if File.directory?(db_location)
			FileUtils.rm_rf(db_location)
		end
		FileUtils.mkdir_p(db_location)
	
		puts("Unziping #{server_name} Database dumps")
		cmd = "7z x #{snap_location}dbdumps.7z -o#{db_location}"
		`#{cmd}`
	else
		puts('Database dumps not found. Skipping...')
	end

	if args.length == 1
		if File.exist?(snap_location + 'bindumps.7z')
			if File.directory?(bin_location)
				FileUtils.rm_rf(bin_location)
			end
			FileUtils.mkdir_p(bin_location)
	
			puts("Unziping #{server_name} Binary dumps")
			cmd = "7z x #{snap_location}bindumps.7z -o#{bin_location}"
			`#{cmd}`
		else
			puts('Binary dumps not found. Skipping...')
		end
	end

	if File.exist?(snap_location + 'confdumps.7z')
		if File.directory?(conf_location)
			FileUtils.rm_rf(conf_location)
		end
		FileUtils.mkdir_p(conf_location)

		puts("Unziping #{server_name} Configs dumps")
		cmd = "7z x #{snap_location}confdumps.7z -o#{conf_location}"
		`#{cmd}`
	else
		puts('Configs dumps not found. Skipping...')
	end
end

if __FILE__ == $0
	args = ARGV
	if args.length == 0
		puts('Not enough arguments.')
		puts('import.rb <server_name> [nobin]')
		abort
	end

	if args.length > 2
		puts('To many arguments.')
		puts('import.rb <server_name> [nobin]')
		abort
	end

	if args.length > 1 && args[1] != 'nobin'
		puts('Unknown second argument')
		puts('Second argument can only be nobin')
		abort
	end

	import(args)
end
