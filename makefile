target := simplecalc

#cflags
clibs       := -lfl -ly
cflags      := -Wall -Werror -g
lexyacc_cflags :=

#dirs
src_dir     := src
build_dir   := build
tests_dir   := tests

#lexyacc
lex_c       := $(src_dir)/lex.yy.c
yacc_c      := $(src_dir)/y.tab.c
yacc_h      := $(src_dir)/y.tab.h
lexyacc_sources := $(lex_c) $(yacc_c)

#sources
lexer       := $(src_dir)/lexer.l
parser      := $(src_dir)/parser.y
sources     := $(filter-out $(lexyacc_sources), $(shell find $(src_dir) -name '*.c'))

# objects
objs        := $(sources:.c=.o)
lexyacc_objs   := $(lexyacc_sources:.c=.o)

#lexyacc flags
lexflags    ?=
yaccflags   ?=

all: $(target)

run: $(target)
	@echo "./$(build_dir)/$(target)"
	@./$(build_dir)/$(target) || exit "$$?"

test: $(target)
	@./test.sh "$(build_dir)/$(target)" "$(tests_dir)"

clean:
	@rm -f $(lexyacc_sources) $(yacc_h)
	@rm -f $(build_dir)/$(target)
	@find . -name '*.o' -delete

clean-all:
	@rm -rf $(build_dir)

$(target): $(build_dir)/$(target)

.PHONY: all clean run test $(target)

$(build_dir)/$(target): $(objs) $(lexyacc_objs) | $(build_dir)
	gcc $(cflags) $(clibs) $(objs) $(lexyacc_objs) -o $@

$(lex_c): $(lexer) $(yacc_h)
	lex $(lexflags) --outfile="$(lex_c)" -- $(lexer)

$(yacc_c) $(yacc_h): $(parser)
	bison $(yaccflags) --output="$(yacc_c)" --header="$(yacc_h)" -- $(parser)

%.o: %.c
	gcc $(cflags) -c $< -o $@

$(lexyacc_objs): $(lex_c) $(yacc_c)
$(lexyacc_objs): %.o: %.c
	gcc $(lexyacc_cflags) -c $< -o $@

$(build_dir):
	@mkdir -p $(build_dir)
