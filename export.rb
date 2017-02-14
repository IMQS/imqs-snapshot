require 'fileutils'

def export(args)
	server_name = args[0]
	snap_location = '\snapper\snapshots\\'
	db_location = '\imqsvar\postgres\*'

	snap_location += server_name

	if File.directory?(snap_location)
		FileUtils.rm_rf(snap_location)
	end
	FileUtils.mkdir_p(snap_location)
	snap_location += '\\'

	cmd = "7z a #{snap_location}dbdumps.7z -m0=lzma2 -mx0 #{db_location}"
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