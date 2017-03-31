require 'fileutils'
require '.\services.rb'

def export(args)
	p7z = 'c:\\imqsbin\\tools\\7z.exe'
	not_found = false
	server_name = args[0]
	snap_location = ''
	server_location = ''
#	postgres_location = 'c:\\imqsvar\\postgres'
	postgres_location = 'c:\\Program\ Files\\PostgreSQL\\9.3\\data'
	mongo_location = 'c:\\imqsvar\\mongo'
	bin_location = 'c:\\imqsbin\\bin'
	conf_location = 'c:\\imqsbin\\conf'

	if !File.directory?(postgres_location)
		puts("Postgres database not found.")
		not_found = true
	end
	if !File.directory?(mongo_location)
		puts("Mongo database not found.")
		not_found = true
	end
	if !File.directory?(bin_location)
		puts("Binarys not found.")
		not_found = true
	end
	if !File.directory?(conf_location)
		puts("Configs not found.")
		not_found = true
	end
	if not_found
		puts("Aborting...")
		abort
	end

	if server_name == 'backup'
		server_location = 'c:\\temp\\backup\\'
	else
		server_location = "t:\\IMQS8_Data\\Servers\\#{server_name}\\"
	end

	snap_location = server_location + 'Snapshot\\'

	cleaner = Thread.new do
		if File.directory?(snap_location)
			loop do
				moved = true
				FileUtils.mv(snap_location, server_location + 'Snapshot_old') rescue moved = false
				
				if moved
					break
				end
				sleep(1)
			end

			FileUtils.rm_rf(server_location + 'Snapshot_old')
		end
	end

	if !File.directory?(server_location + 'Imports')
		FileUtils.mkdir_p(server_location + 'Imports')
	end

	snap_location_new = server_location + 'Snapshot_new\\'
	FileUtils.mkdir_p(snap_location_new)

	postgres_location += '\\*'
	mongo_location += '\\*'
	bin_location += '\\*'
	conf_location += '\\*'

	if __FILE__ == $0
		stop_services_wait()
	end

	puts("Ziping up #{server_name} Postgres database")
	cmd = "#{p7z} a #{snap_location_new}postgres_dump.7z -m0=lzma2 -mx0 #{postgres_location}"
	`#{cmd}`

	puts("Ziping up #{server_name} Mongo database")
	cmd = "#{p7z} a #{snap_location_new}mongo_dump.7z -m0=lzma2 -mx0 #{mongo_location}"
	`#{cmd}`

	puts("Ziping up #{server_name} Binarys")
	cmd = "#{p7z} a #{snap_location_new}bindumps.7z -m0=lzma2 -mx0 #{bin_location}"
	`#{cmd}`
	
	puts("Ziping up #{server_name} Configs")
	cmd = "#{p7z} a #{snap_location_new}confdumps.7z -m0=lzma2 -mx0 #{conf_location}"
	`#{cmd}`

	cleaner.join
	FileUtils.mv(snap_location_new, snap_location)

	puts('Exported system to ' + snap_location)

	if __FILE__ == $0
		start_services_wait()
	end
end

if __FILE__ == $0
	args = ARGV
	if args.length == 0
		puts('Not enough arguments.')
		puts('export.rb <server_name>')
		abort
	end

	if args.length > 1
		puts('To many arguments.')
		puts('export.rb <server_name>')
		abort
	end

	export(args);
end
