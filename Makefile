MODULES:=java/dummy

TSPLIB_MIRROR:=http://comopt.ifi.uni-heidelberg.de/software/TSPLIB95
TSPLIB:=$(TSPLIB_MIRROR)/tsp
TSPLIB_XML:=$(TSPLIB_MIRROR)/XML-TSPLIB/instances
TSPLIB_280:=a280.tsp

DATA_DIR:=data

.PHONY: compile run clean $(MODULES)

all:	$(DATA_DIR) 
	@for mod in $(MODULES); do \
		TEST_FILE=$(CURDIR)/$(DATA_DIR)/$(TSPLIB_280) $(MAKE) -C $$mod run; \
	done

clean:
	rm -rf $(DATA_DIR)
	@for mod in $(MODULES); do \
		$(MAKE) -C $$mod clean; \
	done

$(DATA_DIR):
	mkdir $(DATA_DIR)
	wget -P $(DATA_DIR) $(TSPLIB)/$(TSPLIB_280).gz
	cd $(DATA_DIR); gunzip $(TSPLIB_280).gz

