MODULES:=java/dummy
#cpp/greedy
#rust/2opt

TSPLIB_MIRROR:=http://comopt.ifi.uni-heidelberg.de/software/TSPLIB95
TSPLIB:=$(TSPLIB_MIRROR)/tsp
TSPLIB_XML:=$(TSPLIB_MIRROR)/XML-TSPLIB/instances
TSPLIB_280:=a280

DATA_DIR:=data

TEST_FILE:=$(CURDIR)/$(DATA_DIR)/$(TSPLIB_280)

.PHONY: compile run clean depclean $(MODULES)

all:	$(DATA_DIR) 
	@for mod in $(MODULES); do \
		TEST_FILE=$(TEST_FILE) $(MAKE) -C $$mod run; \
	done

clean:
	@for mod in $(MODULES); do \
		$(MAKE) -C $$mod clean; \
	done

depclean: clean
	rm -rf $(DATA_DIR)

$(DATA_DIR):
	mkdir $(DATA_DIR)
	wget -P $(DATA_DIR) $(TSPLIB)/$(TSPLIB_280).tsp.gz
	cd $(DATA_DIR); gunzip $(TSPLIB_280).tsp.gz
	wget -P $(DATA_DIR) $(TSPLIB_XML)/$(TSPLIB_280).xml.zip
	cd $(DATA_DIR); unzip $(TSPLIB_280).xml.zip
	rm -f $(DATA_DIR)/$(TSPLIB_280_XML).xml.zip
