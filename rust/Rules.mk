CC:=rustc
# In order to allow multiple extensions
# Effectively ovveride RUNCMD from Rules.mk in root.
# The run flags and testfile will be supplied twice but that doesn't matter

include ../../Rules.mk
