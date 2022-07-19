ImageName = fakedata

build:
	docker build . -t $(ImageName)

generate: build	
	$(eval id=$(shell docker create $(ImageName)))
	docker cp $(id):/dids-on-fhir/fake_dids.csv ./fake_dids.csv
	docker cp $(id):/dids-on-fhir/fake_patients.yml ./fake_patients.yml 
	docker rm -v $(id)

