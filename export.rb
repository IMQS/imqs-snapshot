require 'fileutils'
require '.\services.rb'

def export(args)
	not_found = false
	server_name = args[0]
	snap_location = '\snapper\snapshots\\'
	db_location = '\imqsvar\postgres'
	bin_location = '\imqsbin\bin'
	conf_location = '\imqsbin\conf'
	
	snap_location += server_name

	if File.directory?(snap_location)
		FileUtils.rm_rf(snap_location)
	end
	FileUtils.mkdir_p(snap_location)
	snap_location += '\\'

	if !File.directory?(db_location)
		puts("Database not found.")
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

	db_location += '\*'
	bin_location += '\*'
	conf_location += '\*'

	puts("Ziping up #{server_name} Database")
	cmd = "7z a #{snap_location}dbdumps.7z -m0=lzma2 -mx0 #{db_location}"
	`#{cmd}`

	puts("Ziping up #{server_name} Binarys")
	cmd = "7z a #{snap_location}bindumps.7z -m0=lzma2 -mx0 #{bin_location}"
	`#{cmd}`
	
	puts("Ziping up #{server_name} Configs")
	cmd = "7z a #{snap_location}confdumps.7z -m0=lzma2 -mx0 #{conf_location}"
	`#{cmd}`
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
