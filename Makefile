identifier = com.ninxsoft.pkg.kmart
identity_app = Developer ID Application: Nindi Gill (7K3HVCLV7Z)
identity_pkg = Developer ID Installer: Nindi Gill (7K3HVCLV7Z)
binary = kmart
source = .build/apple/Products/release/$(binary)
destination = /usr/local/bin/$(binary)
temp = /private/tmp/$(identifier)
version = $(shell kmart --version | awk '{ print $$1 }')
min_os_version = 12.0
package_dir = build
package = $(package_dir)/Kmart $(version).pkg

build:
	swift build --configuration release --arch arm64 --arch x86_64
	codesign --sign "$(identity_app)" --options runtime "$(source)"

install: build
	install "$(source)" "$(destination)"

package: install
	mkdir -p "$(temp)/usr/local/bin"
	mkdir -p "$(package_dir)"
	cp "$(destination)" "$(temp)$(destination)"
	pkgbuild --root "$(temp)" \
			 --identifier "$(identifier)" \
			 --version "$(version)" \
			 --min-os-version "$(min_os_version)" \
			 --sign "$(identity_pkg)" \
			 "$(package)"
	rm -r "$(temp)"

uninstall:
	rm -rf "$(destination)"

clean:
	rm -rf .build

.PHONY: build install package uninstall clean
