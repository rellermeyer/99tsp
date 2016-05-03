MODULES:=java/dummy

.PHONY: compile run clean $(MODULES)

all: 
	@for mod in $(MODULES); do \
		$(MAKE) -C $$mod run; \
	done

clean:
	@for mod in $(MODULES); do \
		$(MAKE) -C $$mod clean; \
	done
