include config.mk
DATE = `date +'%Y%m%d'`

COMMIT_MESSAGE = $(GH_NAME)
COMMIT_MESSAGE += $(DEV_MESSAGE)
COMMIT_MESSAGE += `date +'%y%m%d%H%M%S'`

dummy:
	echo "test"

symlink:
	./.fix_lua.sh

clone:
	\git clone git@github.com:$(GH_NAME)/valair || \git clone https://github.com/$(GH_NAME)/valair || git clone https://github.com/cmotc/valair; \
	\git clone git@github.com:$(GH_NAME)/sdl2-vapi || \git clone https://github.com/$(GH_NAME)/sdl2-vapi || git clone https://github.com/cmotc/sdl2-vapi; \
	echo "Cloned subprojects"

deinit:
	 \git remote remove github
	cd valair && \git remote remove github
	cd sdl2-vapi && \git remote remove github
	echo "removed pre-init"

init:
	make init-upstream; \
	\git remote add github git@github.com:$(GH_NAME)/lair-manifest
	cd valair && \git remote add github git@github.com:$(GH_NAME)/valair
	cd sdl2-vapi && \git  remote add github git@github.com:$(GH_NAME)/sdl2-vapi
	echo "Initialized Working Remotes"
	make checkout

init-upstream:
	\git remote add upstream git@github.com:cmotc/lair-manifest; \
	cd valair && \git remote add upstream git@github.com:cmotc/valair
	cd sdl2-vapi && \git  remote add upstream git@github.com:cmotc/sdl2-vapi
	echo "Initialized Upstream Remotes"

checkout:
	\git checkout master
	cd valair && \git  checkout mobs
	cd sdl2-vapi && \git  checkout master

commit:
	cd valair && \git add . && \git commit -am "${COMMIT_MESSAGE}"; \
	cd ../sdl2-vapi && \git add . && \git commit -am "${COMMIT_MESSAGE}"; \
	echo "Committed Release:"
	echo "${COMMIT_MESSAGE}"

fetch:
	\git rebase upstream/master; \
	cd valair && \git rebase upstream/mobs; \
	cd ../sdl2-vapi && \git rebase upstream/master; \
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
	cd valair && \git push github mobs; \
	cd ../lair-web && \git push github master;
	echo "Pushed Working Updates"

clean:
	cd valair && make clean; \
	cd ../sdl2-vapi && make clean; \
	cd .. && rm *.buildinfo *.changes *.deb *.deb.md *.dsc *.tar.xz *.tar.gz *.debian.tar.xz *.debian.tar.gz *.orig.tar.gz *.orig.tar.zz; \
	echo "Finished cleaning"

lair:
	export VERSION=$(VERSION);cd valair && make deb-pkg || make deb-upkg
	cd valair && make windows

update-lair:
	export VERSION=$(VERSION);cd valair &&\git add . && \git commit -am "${COMMIT_MESSAGE}"; \
		\git push github mobs

web:
	rm -rf lair-web/lair-deb
	cp -R lair-deb lair-web/lair-deb
	rm -rf lair-web/lair-deb/.git

reweb:
	cd lair-web && make && git add . && git commit -am "new webpage ${COMMIT_MESSAGE}" ; git push github master

update-web:
	export VERSION=$(VERSION);cd lair-web && \git add . && \git commit -am "${COMMIT_MESSAGE}"; \
		\git push github master

sign:
	export KEY=$(KEY); export GH_NAME=$(GH_NAME); ./.do_sign.sh

deb:
	rm lair-deb/packages/*
	cp lair_$(VERSION)-1_amd64.buildinfo \
		lair-deb/packages; \
	cp lairart_$(VERSION)-1_amd64.buildinfo \
		lair-deb/packages; \
	cd lair-deb && ./apt-now

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
	#cd valair && make release; \
	#cd ../sdl2-vapi && make release; \
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

