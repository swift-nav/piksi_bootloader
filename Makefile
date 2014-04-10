SWIFTNAV_ROOT := $(shell pwd)
MAKEFLAGS += SWIFTNAV_ROOT=$(SWIFTNAV_ROOT)

# Be silent per default, but 'make V=1' will show all compiler calls.
ifneq ($(V),1)
Q := @
# Do not print "Entering directory ...".
MAKEFLAGS += --no-print-directory
endif

ifneq (,$(findstring W32,$(shell uname)))
	CMAKEFLAGS += -G "MSYS Makefiles"
endif

.PHONY: all bootloader libopencm3 libswiftnav

all: bootloader

bootloader: libopencm3 libswiftnav
	@printf "BUILD   bootloader\n"; \
	$(MAKE) -C src $(MAKEFLAGS)
	@mv src/bootloader.elf ./
	@mv src/bootloader.hex ./

libopencm3:
	@printf "BUILD   libopencm3\n"; \
	$(MAKE) -C libopencm3 $(MAKEFLAGS) lib/stm32/f4

libswiftnav:
	@printf "BUILD   libswiftnav\n"; \
	mkdir -p libswiftnav/build; cd libswiftnav/build; \
	cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchain-gcc-arm-embedded.cmake $(CMAKEFLAGS) ../
	$(MAKE) -C libswiftnav/build $(MAKEFLAGS)

clean:
	@printf "CLEAN   src\n"; \
	$(MAKE) -C src $(MAKEFLAGS) clean
	@printf "CLEAN   libopencm3\n"; \
	$(MAKE) -C libopencm3 $(MAKEFLAGS) clean
	@printf "CLEAN   libswiftnav\n"; \
	$(RM) -rf libswiftnav/build
	@printf "CLEAN   bootloader\n"; \
	$(RM) -f bootloader.elf \
	$(RM) -f bootloader.hex
