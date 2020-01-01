

# https://github.com/PonnamKarthik/FlutterTrelloCards

# fork: https://github.com/joeblew99/FlutterTrelloCards

LIB_NAME=FlutterTrelloCards
LIB=github.com/joeblew99/$(LIB_NAME)
LIB_BRANCH=master
LIB_FSPATH=$(GOPATH)/src/$(LIB)

GO111MODULE=on

SAMPLE_NAME=
SAMPLE_FSPATH=$(LIB_FSPATH)/$(SAMPLE_NAME)



help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


print: ## print
	@echo
	@echo LIB_NAME: $(LIB_NAME)
	@echo LIB: $(LIB)
	@echo LIB_BRANCH: $(LIB_BRANCH)
	@echo LIB_FSPATH: $(LIB_FSPATH)
	@echo

	@echo
	@echo SAMPLE_NAME: $(SAMPLE_NAME)
	@echo SAMPLE_FSPATH: $(SAMPLE_FSPATH)
	@echo


os-dep:
	# assumes yu have golang installed
	# use brew, scoop based on your OS

	# hover for Flutter Desktop
	go get -u github.com/go-flutter-desktop/hover


### Flu

flu-config: ## flu-config
	flutter config
	flutter doctor -v
	flutter devices

flu-config-desk: ## flu-config-desk
	hover -h


flu-print: ## flu-print
	@echo
	@echo SAMPLE_NAME: $(SAMPLE_NAME)
	@echo SAMPLE_FSPATH: $(SAMPLE_FSPATH)
	@echo
flu-clean:
	cd $(SAMPLE_FSPATH) && flutter clean
flu-update:
	cd $(SAMPLE_FSPATH) && flutter packages get

### New


flu-create:
	@echo NEW_SAMPLE_NAME: $(NEW_SAMPLE_NAME)
	@echo NEW_SAMPLE_FSPATH: $(NEW_SAMPLE_FSPATH)

	cd $(SAMPLE_FSPATH) && cd .. && flutter create example_new
flu-create-pop:
	# copy stuff in
	cp $(SAMPLE_FSPATH)/pubspec.yaml $(NEW_SAMPLE_FSPATH)
	cp -r $(SAMPLE_FSPATH)/lib $(NEW_SAMPLE_FSPATH)
	cp -r $(SAMPLE_FSPATH)/images $(NEW_SAMPLE_FSPATH)
	
	# set specific settings...will do with mage later

### DESK

flu-desk-local-init: ## flu-desk-local-run
	cd $(SAMPLE_FSPATH) && hover init

flu-desk-local-run: ## flu-desk-local-run
	# does not use docker
	cd $(SAMPLE_FSPATH) && hover run

flu-desk-local-build: ## flu-desk-local-build
	# does not use docker
	cd $(SAMPLE_FSPATH) && hover build


flu-desk-build-all: ## flu-desk-build-all
	$(MAKE) flu-desk-build-clean
	$(MAKE) flu-desk-build-init
	$(MAKE) flu-desk-build

flu-desk-build-init: 
	cd $(SAMPLE_FSPATH) && hover init $(LIB)/$(SAMPLE_NAME)

flu-desk-build-clean:
	rm -rf $(SAMPLE_FSPATH)/go

	# this wipes ALL of docker data
	docker system prune
	#docker system prune --force


flu-desk-build:
	# uses docker to build

	cd $(SAMPLE_FSPATH) && hover build darwin
	cd $(SAMPLE_FSPATH) && hover build windows
	# broken: need to look into
	#cd $(SAMPLE_FSPATH) && hover build linux

flu-desk-buildrun: flu-desk-build

	# darwin
	open $(SAMPLE_FSPATH)/go/build/outputs/darwin/
	open $(SAMPLE_FSPATH)/go/build/outputs/darwin/$(SAMPLE)

### Desk Packaging

flu-desk-pack-all: ## flu-desk-pack-all
	$(MAKE) flu-desk-pack-clean
	$(MAKE) flu-desk-pack-init
	$(MAKE) flu-desk-pack

flu-desk-pack-clean:
	rm -rf $(SAMPLE_FSPATH)/go/packaging

	# this wipes ALL of docker data
	docker system prune
	#docker system prune --force




flu-desk-pack-init:

	# Creates any files needed to do packaging.
	# Only needed once.

	# hover init-packaging --help

	#darwin
	cd $(SAMPLE_FSPATH) && hover init-packaging darwin-bundle
	cd $(SAMPLE_FSPATH) && hover init-packaging darwin-pkg

	# windows
	cd $(SAMPLE_FSPATH) && hover init-packaging windows-msi

	# linux
	cd $(SAMPLE_FSPATH) && hover init-packaging linux-appimage
	cd $(SAMPLE_FSPATH) && hover init-packaging linux-deb
	cd $(SAMPLE_FSPATH) && hover init-packaging linux-snap


flu-desk-pack:

	# hover build --help


	# darwin (works)
	# For docker builds on MAC you need to add "/var/folders/wp/" to your docker file sharing.
	#cd $(SAMPLE_FSPATH) && hover build darwin-pkg
	
	# windows (works)
	#cd $(SAMPLE_FSPATH) && hover build windows-msi

	# linux 
	# works
	#cd $(SAMPLE_FSPATH) && hover build linux-deb

	# broken: Issue: https://github.com/go-flutter-desktop/go-flutter/issues/287#issuecomment-544161253
	# marked as "will not fix" because its shitty Ubuntu SnapCraft error.
	# It seems that linux-appimage (https://appimage.org/) works on ubuntu so screw SnapCraft..
	# to install on ubuntu using a appimage is easy: https://askubuntu.com/questions/774490/what-is-an-appimage-how-do-i-install-it
	# We need to try and make sure it works with flutter ! Who has an ubuntu laptop ?

	# Update: works for basic go-flutter example
	cd $(SAMPLE_FSPATH) && hover build linux-snap

	# broken: Issue: https://github.com/go-flutter-desktop/go-flutter/issues/289
	# Marked "as wont fix". So have to ask AppImage team.

	# Update: works for basic go-flutter example
	#cd $(SAMPLE_FSPATH) && hover build linux-appimage
	
flu-desk-pack-open:
	# to see the outputs in your file system.
	open $(SAMPLE_FSPATH)/go/build/outputs


# Will vary per run and machine.
DOCKERTEMP_FSPATH=/var/folders/wp/ff6sz9qs6g71jnm12nj2kbyw0000gp

flu-desk-pack-tmp-list:
	ls /var/folders/wp/
	stat $(DOCKERTEMP_FSPATH)

flu-desk-pack-tmp-clean:
	# clean out docker tmp file dir
	rm -rf $(DOCKERTEMP_FSPATH)

	#ls /var/folders/wp/
	#cd /var/folders/wp/ && rm -rf *
	#ls /var/folders/wp/

flu-desk-pack-tmp-zip:
	# to share whats in tmp
	cd $(DOCKERTEMP_FSPATH) && zip -r -X $(SAMPLE_FSPATH)/go/build/outputs/dockertemp.zip *




### Desk Zipping

flu-desk-dist-all: ## flu-desk-dist-all
	$(MAKE) flu-desk-dist-clean
	$(MAKE) flu-desk-dist-zip
	$(MAKE) flu-desk-dist-unzip

flu-desk-dist-clean:
	rm -rf $(SAMPLE_FSPATH)/dist
	mkdir -p $(SAMPLE_FSPATH)/dist

flu-desk-dist-zip:
	# zip build by OS.

	# darwin
	cd $(SAMPLE_FSPATH)/go/build/outputs/darwin && zip -r -X $(SAMPLE_FSPATH)/dist/darwin.zip *

	# windows
	cd $(SAMPLE_FSPATH)/go/build/outputs/windows && zip -r -X $(SAMPLE_FSPATH)/dist/windows.zip *
	
	# linux
	cd $(SAMPLE_FSPATH)/go/build/outputs/linux && zip -r -X $(SAMPLE_FSPATH)/dist/linux.zip *
	

flu-desk-dist-unzip:
	# clean dist
	rm -rf $(SAMPLE_FSPATH)/dist/out
	mkdir -p $(SAMPLE_FSPATH)/dist/out


	# darwin
	unzip $(SAMPLE_FSPATH)/dist/darwin.zip -d $(SAMPLE_FSPATH)/dist/out/darwin

	# windows
	unzip $(SAMPLE_FSPATH)/dist/windows.zip -d $(SAMPLE_FSPATH)/dist/out/windows
	
	# linux
	unzip $(SAMPLE_FSPATH)/dist/linux.zip -d $(SAMPLE_FSPATH)/dist/out/linux

	

### Mob


flu-mob-run: ## flu-mob-run
	cd $(SAMPLE_FSPATH) && flutter run -d all





### WEB

flu-web-config:
	# flutter channel ?
	#flutter channel dev
	#flutter upgrade

	flutter config --enable-web
	# turn off any desktop
	flutter config --no-enable-linux-desktop
	flutter config --no-enable-macos-desktop
	flutter config --no-enable-windows-desktop
flu-web-create: flu-web-config
	# works 
	# make sure using new dir.
	#mkdir -p $(SAMPLE_FSPATH)
	cd $(SAMPLE_FSPATH) && flutter create simple
flu-web-run: flu-web-config ## flu-web-run
	# works
	# Reload works too :)
	cd $(SAMPLE_FSPATH) && flutter run -d chrome
flu-web-build: flu-web-config ## flu-web-build
	# works :)
	cd $(SAMPLE_FSPATH) && flutter build web --release
flu-web-test: flu-web-config ## flu-web-test
	# works :)
	cd $(SAMPLE_FSPATH) && flutter test --platform=chrome



### i18n

#SAMPLE=keyboard_event
# works

#SAMPLE=mousebuttons
# works

#SAMPLE=pointer_demo
# works and is amazing
# Is perfect sampler, as it has: licenses, setting ( dark mode, debugging)
# TODO: The i18n code is there and working, but there is no easy way to change it in the GUI.
# TODO: Looks like i can use my Google trans gocode to gen more if i can parse the ARBS

stocks-i18n-step1:

	# generate ui code --> i18n code ( intl_messages.arb from lib/stock_strings.dart )
	cd $(LIB_FSPATH)/$(SAMPLE) && flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/i18n lib/stock_strings.dart
	ls -al cd $(LIB_FSPATH)/$(SAMPLE)/lib/i18n

stocks-i18n-step2:
	# generate arb string --> i18n code (a stock_messages_<locale>.dart for each stocks_<locale>.arb file and stock_messages_all.dart)
	cd $(LIB_FSPATH)/$(SAMPLE) && flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/i18n \
   --generated-file-prefix=stock_ --no-use-deferred-loading lib/*.dart lib/i18n/stocks_*.arbs
    # Now you have all the "stock_messages_all, en, es.dart regenerated
	# Its used the stocks_en,es.arb as sources
	# Now each of the locale i18n dart code is populated with the translated string.
	
	





