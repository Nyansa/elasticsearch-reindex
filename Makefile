.PHONY: clean package install deploy

PACKAGE_PATH = $(shell ls ./target/elasticsearch-*zip)
PACKAGE = $(shell basename $(PACKAGE_PATH))

define INSTALL_PLUGIN_SCRIPT
sudo /usr/share/elasticsearch/bin/plugin --remove reindex; \
sudo /usr/share/elasticsearch/bin/plugin --url file:///tmp/$(PACKAGE) --install reindex && \
sudo service elasticsearch restart; \
echo 'Restarted Elasticsearch, sleeping for 1 minute...' && \
sleep 60;
endef

define DEPLOY_SERVER
	echo "Deploying $(PACKAGE) to $(server)"
	scp $(PACKAGE_PATH) $(server):/tmp/$(PACKAGE)
	ssh $(server) "$(INSTALL_PLUGIN_SCRIPT)"
endef

clean:
	mvn clean

package:
	mvn -DskipTests package

install: clean package
	plugin --remove reindex
	plugin --url file:$(PACKAGE_PATH) --install reindex
	@echo "Installed $(PACKAGE)"

deploy: clean package
	$(foreach server,$(SERVER),$(DEPLOY_SERVER))
