.PHONY: build run bump publish

bump:
	docker run --rm -i -v ${CURDIR}:/app -w /app treeder/bump --filename pubspec.yaml bump

publish: bump
	git commit -am "bump version"
	git push
	flutter pub publish -f
	
