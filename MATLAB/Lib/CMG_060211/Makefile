#------------------------------------------------------------------------------#
#                                                                              #
#                                MAKE OPTIONS                                  #
#                                                                              #
#------------------------------------------------------------------------------#
ALL_TARGETS :=

.SUFFIXES:
.DEFAULT: release
release:


#------------------------------------------------------------------------------#
#                                                                              #
#                                FIND MATLAB                                   #
#                                                                              #
#------------------------------------------------------------------------------#
MATLAB_DIR := $(shell matlab -e 2>/dev/null | sed -n 's/MATLAB=\(.\+\)/\1/p')
ARCH       := $(shell matlab -e 2>/dev/null | sed -n 's/ARCH=\(.\+\)/\1/p')

#------------------------------------------------------------------------------#
#                                                                              #
#                              UTILITY MACROS                                  #
#                                                                              #
#------------------------------------------------------------------------------#

# $(call parse-mex-options,OPTION_NAME)
# Parse options from the mex compiler.
define parse-mex-options
$(shell $(MXX) -v 2>/dev/null | sed -n 's/\s*$1\s*=\s*\(\(-.\+\s\+\)\+\)/\1/p')
endef

# $(call pretty,STRING)
# Remove duplicate whitespace from a string. Removes the following:
#     - Repeated whitespace
#     - Leading whitespace
#     - Trailing whitespace
define pretty
$(shell echo -n "$1" | sed \
-e 's/\s\s\+/ /' \
-e 's/^\s\+//' \
-e 's/\s\+$$//'
)
endef

# $(call remove-flag,FLAGS,FLAG)
# Remove a flag from a CFLAG-style string.
define remove-flag
$(shell echo -n $1 | sed 's/-$2\s\+//')
endef

#-------------------------------------------------------------------------------

# $(call matlab-target-template,TARGET)
define matlab-target-template
$(1)_TARGET   := $$(OUTPUT_DIR)/Hierarchy/MexFunctions/$(1).$$(MEXEXT)
$(1)_SOURCES  := $$(SOURCE_DIR)/Hierarchy/$(1).c
$(1)_CFLAGS   :=
$(1)_CXXFLAGS :=
$(1)_MXXFLAGS :=

$(call target-template,$(1))
endef

# $(call target-template,TARGET)
define target-template
ALL_TARGETS += $$($(1)_TARGET)

$$($(1)_TARGET): $$($(1)_SOURCES)
	-@echo "Compiling: $$@"
	$$(call pretty,$$(MXX) $$(MXXFLAGS) $$($(1)_MXXFLAGS) CFLAGS='$$(CFLAGS) $$($(1)_CFLAGS)' CXXFLAGS='$$(CXXFLAGS) $$($(1)_CXXFLAGS)' LDFLAGS='$$(LDFLAGS)' -o $$@ $$^)
	-@echo
endef


#------------------------------------------------------------------------------#
#                                                                              #
#                            ARCHITECTURE VARIABLES                            #
#                                                                              #
#------------------------------------------------------------------------------#
ifndef MXX
	ifeq ($(shell uname),Darwin)
		MXX      := $(call pretty,$(MATLAB_DIR)/bin/mex -$(ARCH))
		MEXEXT   := $(shell $(MATLAB_DIR)/bin/mexext)
		MXXFLAGS := -I$(MATLAB_DIR)/extern/include
	endif
	ifeq ($(shell uname),Linux)
		MXX      := $(call pretty,$(MATLAB_DIR)/bin/mex -$(ARCH))
		MEXEXT   := $(shell $(MATLAB_DIR)/bin/mexext)
		MXXFLAGS := -I$(MATLAB_DIR)/extern/include
	endif
else
	MEXEXT := $(shell MEXEXT)
endif

ifeq ($(ARCH),glnx86)
	MEXEXT    := mexglx
	ARCH_TYPE := x86
endif
ifeq ($(ARCH),glnxa64)
	MEXEXT    := mexa64
	ARCH_TYPE := x64
endif
ifeq ($(ARCH),mac)
	MEXEXT    := mexmac
	ARCH_TYPE := x86
endif
ifeq ($(ARCH),maci)
	MEXEXT    := mexmaci
	ARCH_TYPE := x86
endif
ifeq ($(ARCH),maci64)
	MEXEXT    := mexmaci64
	ARCH_TYPE := x64
endif
ifeq ($(ARCH),sol2)
	MEXEXT    := mexsol
	ARCH_TYPE := x86
endif
ifeq ($(ARCH),sol64)
	MEXEXT    := mexs64
	ARCH_TYPE := x64
endif
ifeq ($(ARCH),win64)
	MEXEXT    := mexw64
	ARCH_TYPE := x64
endif
ifeq ($(ARCH),win32)
	MEXEXT    := mexw32
	ARCH_TYPE := x86
endif


#------------------------------------------------------------------------------#
#                                                                              #
#                              COMPILER FLAGS                                  #
#                                                                              #
#------------------------------------------------------------------------------#

# Default flags (these will be overridden)
CFLAGS   := $(call parse-mex-options,CFLAGS)
CXXFLAGS := $(call parse-mex-options,CXXFLAGS)
LDFLAGS  := $(call parse-mex-options,LDFLAGS)

# Remove 'ANSI standard' flags
CFLAGS   := $(call remove-flag,$(CFLAGS),ansi)
CXXFLAGS := $(call remove-flag,$(CXXFLAGS),ansi)

# Additional flags
CFLAGS   += -std=c99 -pedantic -fmessage-length=0
CXXFLAGS += -std=c++0x -pedantic -fmessage-length=0
MXXFLAGS +=
LDFLAGS  +=

# Architecture specific
ifeq ($(ARCH_TYPE), x86)
CFLAGS   +=
CXXFLAGS +=
MXXFLAGS += -compatibleArrayDims
LDFLAGS  +=
endif
ifeq ($(ARCH_TYPE), x64)
CFLAGS   +=
CXXFLAGS +=
MXXFLAGS += -largeArrayDims
LDFLAGS  +=
endif

# Debug flags
CFLAGS_DEBUG   := -g -O0
CXXFLAGS_DEBUG := -g -O0
MXXFLAGS_DEBUG := -DDEBUG
LDFLAGS_DEBUG  := -g

# Optimization flags
CFLAGS_OPT   := -O3
CXXFLAGS_OPT := -O3
MXXFLAGS_OPT := -O -DNDEBUG
LDFLAGS_OPT  := -O3


#------------------------------------------------------------------------------#
#                                                                              #
#                              DEPENDENCY RULES                                #
#                                                                              #
#------------------------------------------------------------------------------#

SOURCE_DIR := Source
OUTPUT_DIR := MATLAB
MXXFLAGS   += -IInclude

# MATLAB targets
MATLAB_TARGETS := adjacency_cmg diagconjugate forest_components graphprofile laplacian2 perturbtril splitforest update_groups vpack
$(foreach TARGET,$(MATLAB_TARGETS),$(eval $(call matlab-target-template,$(TARGET))))

# Solver targets
SOLVER_COMMON := vpv vmv vpvmv vvmul rmvec ldl_solve spmv sspmv preconditioner

mx_s_preconditioner_TARGET   := $(OUTPUT_DIR)/Solver/mx_s_preconditioner.$(MEXEXT)
mx_s_preconditioner_SOURCES  := $(OUTPUT_DIR)/Solver/mx_s_preconditioner.c $(foreach file,$(SOLVER_COMMON),$(SOURCE_DIR)/Solver/$(file).c)
mx_s_preconditioner_CFLAGS   := -DSINGLE_PR
mx_s_preconditioner_CXXFLAGS := -DSINGLE_PR
mx_s_preconditioner_MXXFLAGS := -DSINGLE_PR
$(eval $(call target-template,mx_s_preconditioner))

mx_d_preconditioner_TARGET   := $(OUTPUT_DIR)/Solver/mx_d_preconditioner.$(MEXEXT)
mx_d_preconditioner_SOURCES  := $(OUTPUT_DIR)/Solver/mx_d_preconditioner.c  $(foreach file,$(SOLVER_COMMON),$(SOURCE_DIR)/Solver/$(file).c)
mx_d_preconditioner_CFLAGS   :=
mx_d_preconditioner_CXXFLAGS :=
mx_d_preconditioner_MXXFLAGS :=
$(eval $(call target-template,mx_d_preconditioner))


#------------------------------------------------------------------------------#
#                                                                              #
#                                  TARGETS                                     #
#                                                                              #
#------------------------------------------------------------------------------#

# Release build
release: CFLAGS   += $(CFLAGS_OPT)
release: CXXFLAGS += $(CXXFLAGS_OPT)
release: MXXFLAGS += $(MXXFLAGS_OPT)
release: LDFLAGS  += $(LDFLAGS_OPT)
release: all

# Debug build
debug:   CFLAGS   += $(CFLAGS_DEBUG)
debug:   CXXFLAGS += $(CXXFLAGS_DEBUG)
debug:   MXXFLAGS += $(MXXFLAGS_DEBUG)
debug:   LDFLAGS  += $(LDFLAGS_DEBUG)
debug:   all

.PHONY: all
all: $(ALL_TARGETS)
	-@echo "Done."

#------------------------------------------------------------------------------#
#                                                                              #
#                               CLEAN TARGETS                                  #
#                                                                              #
#------------------------------------------------------------------------------#
.PHONY: clean
clean:
	-@echo "Cleaning..."
	$(call pretty,rm -f $(ALL_TARGETS))
	-@echo "Clean completed."

.PHONY: distclean
distclean: clean
