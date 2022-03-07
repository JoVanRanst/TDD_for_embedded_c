# ====================================================== #
#   TDD Embedded C Project: coding to acompany the book
#   This file is developed by Jo Van Ranst
#   Heavily based on the Unity Project makefile example
# ====================================================== #

# OS command adjustments
ifeq ($(OS),Windows_NT)
  ifeq ($(shell uname -s),) # not in a bash-like shell
	CLEANUP = del /F /Q
	MKDIR = mkdir
  else # in a bash-like shell, like msys
	CLEANUP = rm -f
	MKDIR = mkdir -p
  endif
	TARGET_EXTENSION=exe
else
	CLEANUP = rm -f
	MKDIR = mkdir -p
	TARGET_EXTENSION=out
endif

# ====================================================== #
#   Compiler settings
# ====================================================== #
COMPILE=gcc -c
LINK=gcc
DEPEND=gcc -MM -MG -MF


# ====================================================== #
#   Source file paths.
#   -> make to match your file structure
# ====================================================== #
# Unity files folders
UNITY_ROOT = unity/
PATHU = $(UNITY_ROOT)src/
SRCU = $(wildcard $(PATHU)*.c)
# PATHF = $(UNITY_ROOT)extras/fixture/src/
# SRCF = $(wildcard $(PATHF)*.c)
# PATHM = $(UNITY_ROOT)extras/memory/src/
# SRCM = $(wildcard $(PATHM)*.c)
# Code source file folder
PATHS = src/
SRCS = $(wildcard $(PATHS)*.c)
# Test source file folder
PATHT = test/
PATHTR = $(PATHT)test_runners/
SRCT = $(wildcard $(PATHT)*.*) $(wildcard $(PATHTR)*.c)
SOURCE_FILES =$(SRCU) $(SRCF) $(SRCM) $(SRCS) $(SRCT)

# Compiler flags
CFLAGS =
# CFLAGS +=-std=c89
# CFLAGS += -Wall
# CFLAGS += -Wextra
# CFLAGS += -Wpointer-arith
# CFLAGS += -Wcast-align
# CFLAGS += -Wwrite-strings
# CFLAGS += -Wswitch-default
# CFLAGS += -Wunreachable-code
# CFLAGS += -Winit-self
# CFLAGS += -Wmissing-field-initializers
# CFLAGS += -Wno-unknown-pragmas
# CFLAGS += -Wstrict-prototypes
# CFLAGS += -Wundef
# CFLAGS += -Wold-style-definition
#CFLAGS += -Wno-misleading-indentation
CFLAGS+=-I $(PATHS)
CFLAGS_TEST=$(CFLAGS) -I $(PATHU)
# CFLAGS_TEST+=-I $(PATHF)
# CFLAGS_TEST+=-I $(PATHM)
CFLAGS_TEST+=-I $(PATHT)
CFLAGS_TEST+=-I $(PATHTR)
CFLAGS_TEST+= $(CFLAGS) -DTEST

# Build paths
PATHB = build/
PATHD = build/depends/
PATHO = build/objs/
PATHR = build/results/
BUILD_PATHS = $(PATHB) $(PATHD) $(PATHO) $(PATHR)

# Result variables
RESULTS = $(patsubst $(PATHT)%.c,$(PATHR)%.txt,$(SRCT) )
PASSED = `grep -s PASS $(PATHR)*.txt`
FAIL = `grep -s FAIL $(PATHR)*.txt`
IGNORE = `grep -s IGNORE $(PATHR)*.txt`


.PHONY: $(PATHTR)$(TEST1_RUNNER).c
TEST1 = FirstTest
TEST1_RUNNER = $(TEST1)_Runner.c

# Output files
TARGET = $(TEST1).$(TARGET_EXTENSION)

# Build versions
all: clean test run

release: $(SRCS)
	$(LINK) $(CFLAGS) $(SRCS) -o $(PATHB)$(TARGET)
run:
	- ./$(PATHB)$(TARGET)

test: $(SOURCE_FILES)
	$(LINK) $(CFLAGS_TEST) $(SOURCE_FILES) -o $(PATHB)Test$(TARGET)
	- ./$(PATHB)Test$(TARGET)


$(PATHTR)$(TEST1_RUNNER).c: test/$(TEST1).c
	ruby $(UNITY_ROOT)/auto/generate_test_runner.rb test/$(TEST1).c $(PATHTR)$(TEST1_RUNNER).c





# ====================================================== #
#   "make clean"
#   removes all object files, the executables and the
#   test result files. (not linked to .PRECIOUS list)
# ====================================================== #
clean:
	$(CLEANUP) $(PATHO)*.o
	$(CLEANUP) $(PATHB)*.$(TARGET_EXTENSION)
	$(CLEANUP) $(PATHR)*.txt

# ====================================================== #
#   List of files to keep at the end of a build run.
#   -> add or remove as you see fit
# ====================================================== #
.PRECIOUS: $(PATHB)%.$(TARGET_EXTENSION)
.PRECIOUS: $(PATHD)%.d
.PRECIOUS: $(PATHO)%.o
.PRECIOUS: $(PATHR)%.txt

# ====================================================== #
#   Test seperator
# ====================================================== #
# test_seperate: $(BUILD_PATHS) $(RESULTS)
# 	@echo $(RESULTS)
# 	@echo "-----------------------\nIGNORES:\n-----------------------"
# 	@echo "$(IGNORE)"
# 	@echo "-----------------------\nFAILURES:\n-----------------------"
# 	@echo "$(FAIL)"
# 	@echo "-----------------------\nPASSED:\n-----------------------"
# 	@echo "$(PASSED)"
# 	@echo "\nDONE"

# $(PATHR)%.txt: $(PATHB)%.$(TARGET_EXTENSION)
# 	-./$< > $@ 2>&1

# $(PATHB)%.$(TARGET_EXTENSION): $(PATHO)%.o $(PATHO)%.o $(PATHU)unity.o #$(PATHD)Test%.d
# 	$(LINK) -o $@ $^

# # Test folder
# # $(PATHO)%.o:: $(PATHT)%.c
# # 	$(COMPILE) $(CFLAGS_TEST) $< -o $@
# # Test runner subfolder
# $(PATHO)%.o:: $(PATHTR)%_Runner.c
# 	$(COMPILE) $(CFLAGS_TEST) $< -o $@
# # source folder
# $(PATHO)%.o:: $(PATHS)%.c
# 	$(COMPILE) $(CFLAGS_TEST) $< -o $@
# # Unity folder
# $(PATHO)%.o:: $(PATHU)%.c $(PATHU)%.h
# 	$(COMPILE) $(CFLAGS_TEST) $< -o $@
# ====================================================== #
#   Helper calls
# ====================================================== #

# Adders for the outupt directory tree
$(PATHB):
	$(MKDIR) $(PATHB)
$(PATHD):
	$(MKDIR) $(PATHD)
$(PATHO):
	$(MKDIR) $(PATHO)
$(PATHR):
	$(MKDIR) $(PATHR)

# Dependency checker
$(PATHD)%.d:: $(PATHT)%.c
	$(DEPEND) $@ $<
