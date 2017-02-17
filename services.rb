require "json"

# These services are stopped before a import or build starts
AllServices = [
    {name: 'imqs-configuration-service'}, # Configuration service must be first, because most other services depend on it
    {name: 'ImqsCpp'},
    {name: 'ImqsRouter'},
    {name: 'real-time-service'},
    {name: 'ImqsDistributer'},
    {name: 'ImqsDocs'},
    {name: 'ImqsMongo'},
    {name: 'ImqsAuth'},
    {name: 'imqs-pcs-webservice'},
    {name: 'ImqsInfraIntegration'},
    {name: 'imqs-formbuilder'},
    {name: 'imqs-workforce'},
    {name: 'imqs-maintm-loglite'},
    {name: 'imqs-maintm-workflow'},
    {name: 'ImqsSearch'},
    {name: 'ImqsScheduler'},
    {name: 'imqs-sap-notifications'},
    {name: 'imqs-sap-operations'},
    {name: 'imqs-sap-web-services'},
    {name: 'ImqsLogScraper'},
    {name: 'imqs-datamodel-queries'},
    {name: 'ImqsWwwServer'},
    {name: 'ImqsUploadService'},
    {name: 'ImqsInSite', must_start: false},
    {name: 'ImqsSiteView', must_start: false},
    {name: 'ImqsTimeSeries', must_start: false},
    {name: 'ImqsDBWatchdog'},
    {name: 'imqs-wip-service'},
    {name: 'ImqsMessaging'},
    {name: 'ImqsChat'},
    {name: 'ImqsCrud'},
    {name: 'imqs-asset-photo-service'}
]

# This is a synchronous version of stopping services (waits for return)
def stop_services_wait(timeout_seconds = 10)
	puts('Stoping all services')

	start = Time.now
	nstarted = 0
	AllServices.each { |service|
		name = service[:name]
		puts("Stopping #{name}")
		res = `net stop #{name}`
		puts('Service successfully stopped') if res
		puts('Service not running') unless res
		nstarted += 1 if res.include? 'service was stopped successfully'
	}
	puts('Service shutdown exceeded specified time') if Time.now - start >= timeout_seconds
	return nstarted == AllServices.length
end

# This is a synchronous version of starting services (waits for return)
def start_services_wait(timeout_seconds = 10)
	puts('Starting all services')

	start = Time.now
	nstarted = 0
	AllServices.each do |service|
		name = service[:name]
		puts("Starting #{name}")
		res = `net start #{name}`
		puts('Service started') if res
		puts('Service not started') unless res
		nstarted += 1 if res.include? "service was started successfully"
	end
	puts('Service start up exceeded specified time') if Time.now - start >= timeout_seconds
	return nstarted == names.length
end
