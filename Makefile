include config.mk
DATE = `date +'%Y%m%d'`

COMMIT_MESSAGE = $(GH_NAME)
COMMIT_MESSAGE += $(DEV_MESSAGE)
COMMIT_MESSAGE += `date +'%y%m%d%H%M%S'`

dummy:
	echo "test"

clone:
	\git clone git@github.com:$(GH_NAME)/tablet-manifest . || \git clone https://github.com/$(GH_NAME)/u-boot || git clone https://github.com/cmotc/tablet-manifest .; \
	\git clone git@github.com:$(GH_NAME)/u-boot || \git clone https://github.com/$(GH_NAME)/u-boot || git clone https://github.com/cmotc/u-boot; \
	\git clone git@github.com:$(GH_NAME)/imgmaker || \git clone https://github.com/$(GH_NAME)/imgmaker || git clone https://github.com/cmotc/imgmaker; \
	echo "Cloned subprojects"

deinit:
	 \git remote remove github
	cd u-boot && \git remote remove github
	cd imgmaker && \git remote remove github
	echo "removed pre-init"

init:
	make init-upstream; \
	\git remote add github git@github.com:$(GH_NAME)/tablet-manifest
	cd u-boot && \git remote add github git@github.com:$(GH_NAME)/u-boot
	cd imgmaker && \git  remote add github git@github.com:$(GH_NAME)/imgmaker
	echo "Initialized Working Remotes"
	make checkout

init-upstream:
	\git remote add upstream git@github.com:cmotc/tablet-manifest; \
	cd u-boot && \git remote add upstream git@github.com:cmotc/u-boot
	cd imgmaker && \git  remote add upstream git@github.com:cmotc/imgmaker
	echo "Initialized Upstream Remotes"

checkout:
	\git checkout master
	cd u-boot && \git  checkout master
	cd imgmaker && \git  checkout new-master

commit:
	\git add . && \git commit -am "${COMMIT_MESSAGE}"; \
	cd u-boot && \git add . && \git commit -am "${COMMIT_MESSAGE}"; \
	cd ../imgmaker && \git add . && \git commit -am "${COMMIT_MESSAGE}"; \
	echo "Committed Release:"
	echo "${COMMIT_MESSAGE}"

fetch:
	\git rebase upstream/master; \
	cd u-boot && \git rebase upstream/master; \
	cd ../imgmaker && \git rebase upstream/new-master; \
	echo "Pulled in updates"

pull:
	make commit
	make fetch

update:
	make commit
	repo sync --force-sync || make fetch

force-update:
	make clean; \
	rm -rf */* */.git */.repo .git/; \
	repo sync --force-sync || make fetch \
	make init

upload:
	\git push github master; \
	cd u-boot && \git push github master; \
	cd imgmaker && \git push github new-master; \
	cd ../tab-web && \git push github master;
	echo "Pushed Working Updates"

clean:
	cd u-boot && make clean; \
	cd ../imgmaker && make clean; \
	cd .. && rm *.buildinfo *.changes *.deb *.deb.md *.dsc *.tar.xz *.tar.gz *.debian.tar.xz *.debian.tar.gz *.orig.tar.gz *.orig.tar.zz; \
	echo "Finished cleaning"

uboot:
	export VERSION=$(VERSION);cd u-boot && make deb-pkg || make deb-upkg

update-uboot:
	export VERSION=$(VERSION);cd u-boot &&\git add . && \git commit -am "${COMMIT_MESSAGE}"; \
		\git push github master

web:
	rm -rf tab-web/tab-deb
	cp -R tab-deb tab-web/tab-deb
	rm -rf tab-web/tab-deb/.git

reweb:
	cd tab-web && make && git add . && git commit -am "new webpage ${COMMIT_MESSAGE}" ; git push github master

update-web:
	export VERSION=$(VERSION);cd tab-web && \git add . && \git commit -am "${COMMIT_MESSAGE}"; \
		\git push github master

sign:
	export KEY=$(KEY); export GH_NAME=$(GH_NAME); ./.do_sign.sh

deb:
	rm tab-deb/packages/*
	cp lair_$(VERSION)-1_amd64.buildinfo \
		tab-deb/packages; \
	cp lairart_$(VERSION)-1_amd64.buildinfo \
		tab-deb/packages; \
	cd tab-deb && ./apt-now

full:
	gpg --batch --yes --clear-sign -u $(KEY) README.md
	echo "Rebuilt the whole suite"

push:
	gpg --batch --yes --clear-sign -u $(KEY) README.md
	#make reweb
	make commit
	make upload

version:
	echo 'version placeholder'
	#cd u-boot && make release; \
	#cd ../imgmaker && make release; \
	#cd .. && make release \
	#echo 'Made new Version Numbers'

release:
	make version
	gpg --batch --yes --clear-sign -u $(KEY) README.md
	make full
	make sign
	make reweb
	make push
	repo sync

#Don't use this yet, it's teaching me about what needs to exist to make the code
#run modules and plugins from configrable locations right now.

