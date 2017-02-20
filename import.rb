require 'fileutils'
require '.\services.rb'
require '.\export.rb'

def import(args)
	server_name = args[0]
	snap_location = ''
	postgres_location = '\imqsvar\postgres'
	mongo_location = '\imqsvar\mongo'
	bin_location = '\imqsbin\bin'
	conf_location = '\imqsbin\conf'

	if server_name == 'backup'
		snap_location = '\temp\backup'
	else
		snap_location = '\snapper\snapshots\\' + server_name
	end

	if !File.directory?(snap_location)
		puts("Snapshot #{server_name} not found. Aborting...")
		abort
	end

	if (File.directory?(postgres_location) && File.directory?(mongo_location) &&
		File.directory?(bin_location) && File.directory?(conf_location) &&
		!File.directory?('/temp/backup'))
		puts('Found existing system with no backup. Making backup.')
		export([ 'backup' ])
		puts('Importing snapshot')
	end

	stop_services_wait()

	snap_location += '\\'

	if File.exist?(snap_location + 'dbdumps\postgres_dump.7z')
		if File.directory?(postgres_location)
			FileUtils.rm_rf(postgres_location)
		end
		FileUtils.mkdir_p(postgres_location)
	
		puts("Unziping #{server_name} Postgres database dump")
		cmd = "7z x #{snap_location}dbdumps\postgres_dump.7z -o#{postgres_location}"
		`#{cmd}`
	else
		puts('Postgres database dump not found. Skipping...')
	end
	
	if File.exist?(snap_location + 'dbdumps\mongo_dump.7z')
		if File.directory?(mongo_location)
			FileUtils.rm_rf(mongo_location)
		end
		FileUtils.mkdir_p(mongo_location)
	
		puts("Unziping #{server_name} Mongo database dump")
		cmd = "7z x #{snap_location}dbdumps\mongo_dump.7z -o#{mongo_location}"
		`#{cmd}`
	else
		puts('Mongo database dumps not found. Skipping...')
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

	start_services_wait()
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
