require 'fileutils'
require '.\services.rb'

POSTGRES_INSTALL_DIR = 'c:\Program Files\PostgreSQL\9.3'
POSTGRES_BIN_DIR = POSTGRES_INSTALL_DIR + '\bin'
POSTGRES_INITDB = POSTGRES_BIN_DIR + '\initdb'
POSTGRES_PASSWORD_JSON_FILE = 'c:\imqsbin\conf\secrets.json'
POSTGRES_DATA = 'c:\imqsvar\postgres'

def build(args)
	server_name = args[0]
	snap_location = 't:\IMQS8_Data\Snapshots\\'
	import_location = snap_location + server_name + '\imports\\'
	staging_location = 'c:\imqsvar\imports'

	if !File.directory?(import_location)
		puts('Import directory does not exist. Aborting...')
		abort
	end
	
	imports = []
	Dir.entries(import_location).select { |f|
		if !File.directory? f
			imports.push(import_location + f)
		end
	}
	if imports.length == 0
		puts('Import directory is empty. Nothing to import. Aborting...')
		abort
	end
	
	init_postgres()

	puts('Creating testing users')
	Dir.chdir('c:\imqsbin\bin') do
		`imqsauth.exe createuser testadmin 123`
		`imqsauth.exe permgroupadd testadmin admin`
		`imqsauth.exe permgroupadd testadmin enabled`

		`imqsauth.exe createuser testnormal 123`
		`imqsauth.exe permgroupadd testnormal enabled`
	end

	puts('Importing... This may take a while')
	imports.each { |i|
		puts('Import: ' + i)
		loop do
			staging = 0
			Dir.entries(staging_location).select { |s|
				if File.file?(s)
					puts('Staging: ' + s)
					staging += 1
				end
			}
			if staging > 0
				sleep(10)
			else
				FileUtils.cp(i, staging_location)
				break
			end
		end
	}
end

def init_postgres()
	stop_services_wait()

	puts('Wiping postgres database.')
	if File.directory?(POSTGRES_DATA)
		FileUtils.rm_rf(POSTGRES_DATA)
	end
	FileUtils.mkdir_p(POSTGRES_DATA)

	puts('Creating clean postgres database.')
	secrets = File.read(POSTGRES_PASSWORD_JSON_FILE)
	pwd = JSON::parse(secrets)["PostgresMasterPassword"]
	ENV['PGPASSWORD'] = pwd
	pwd_file = 'c:\imqsvar\pgpasswd'
	File.write(pwd_file, pwd)
	`\"#{POSTGRES_INITDB}\" --encoding=UTF8 --auth-host=md5 --username=postgres --pwfile=#{pwd_file} #{POSTGRES_DATA}`
	File.delete(pwd_file)

	`takeown /a /f #{POSTGRES_DATA.gsub('/', '\\')} /r`

	start_service('Postgres')

	psql_stub = "\"#{POSTGRES_BIN_DIR}\\psql\" --host=localhost --username=postgres -c"
	sql = "CREATE ROLE imqs SUPERUSER CREATEDB CREATEROLE REPLICATION LOGIN PASSWORD '#{pwd}'"
	`#{psql_stub} \"#{sql}\"`
	
	Dir.chdir('c:\imqsbin') do
		puts('Creating user keys')
		`ruby installers\\key_management.rb`
		puts('Running last configuration')
		`ruby installers\\install.rb -prod`
	end
	puts('Done seting up new postgres database')
	start_services_wait()
end

if __FILE__ == $0
	args = ARGV
	if args.length == 0
		puts('Not enough arguments.')
		puts('build.rb <server_name>')
		abort
	end

	if args.length > 1
		puts('To many arguments.')
		puts('build.rb <server_name>')
		abort
	end

	build(args)
end