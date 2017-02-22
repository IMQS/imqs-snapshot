require "json"

# These services are stopped before a import or build starts
# Uncommented services where not found running after initial server setup.
AllServices = [
	{name: 'imqs-configuration-service'}, # Configuration service must be first, because most other services depend on it
	{name: 'Postgres'},
	{name: 'ImqsYellowfin'},
	{name: 'ImqsCpp'},
	{name: 'ImqsRouter'},
	{name: 'ImqsAuth'},
#	{name: 'real-time-service'},
	{name: 'ImqsDistributer'},
	{name: 'ImqsMongo'},
	{name: 'ImqsDocs'},
#	{name: 'imqs-pcs-webservice'},
#	{name: 'ImqsInfraIntegration'},
#	{name: 'imqs-formbuilder'},
#	{name: 'imqs-workforce'},
#	{name: 'imqs-maintm-loglite'},
#	{name: 'imqs-maintm-workflow'},
#	{name: 'ImqsScheduler'},
#	{name: 'imqs-sap-notifications'},
#	{name: 'imqs-sap-operations'},
#	{name: 'imqs-sap-web-services'},
#	{name: 'ImqsLogScraper'},
#	{name: 'imqs-datamodel-queries'},
	{name: 'ImqsWwwServer'},
	{name: 'ImqsUploadService'},
#	{name: 'ImqsInSite', must_start: false},
#	{name: 'ImqsSiteView', must_start: false},
#	{name: 'ImqsTimeSeries', must_start: false},
#	{name: 'ImqsDBWatchdog'},
#	{name: 'imqs-wip-service'},
#	{name: 'ImqsMessaging'},
#	{name: 'ImqsChat'},
	{name: 'ImqsCrud'},
#	{name: 'imqs-asset-photo-service'},
	{name: 'ImqsConversion'},
	{name: 'ImqsCouchDB'},
	{name: 'imqs-esri-importer'},
	{name: 'ImqsGoFin'},
	{name: 'ImqsSpatialLinker'},
	{name: 'ImqsSearch'},
	{name: 'ImqsPentago'},
	{name: 'ImqsScheduler'}
]

# This is a synchronous version of stopping services (waits for return)
def stop_services_wait(timeout_seconds = 10)
	puts('Stoping all services')
	print("(0/#{AllServices.length})")

	nstoped = 0
	AllServices.reverse.each { |service|
		name = service[:name]
		res = `net stop #{name} /y 2>&1`
		if res.include?('service was stopped successfully') || res.include?('service is not started')
			nstoped += 1
		else
			print("\r#{name}: #{res} \n")
		end
		print("\r(#{nstoped}/#{AllServices.length})")
	}
	puts(' done.')
end

# This is a synchronous version of starting services (waits for return)
def start_services_wait(timeout_seconds = 10)
	puts('Starting all services')
	print("(0/#{AllServices.length})")

	nstarted = 0
	AllServices.each { |service|
		name = service[:name]
		res = `net start #{name} 2>&1`
		if res.include?('service was started successfully')
			nstarted += 1 
		else
			print("\rService #{name} could not be started\n")
		end
		print("\r(#{nstarted}/#{AllServices.length})")
	}
	puts(' done.')
end

def start_service(name)
	puts("Starting service #{name}")
	res = `net start #{name} 2>&1`
	if res.include?('service was started successfully')
		puts("Service #{name} was started successfully")
	else
		puts("Service #{name} could not be started\n")
	end
end
