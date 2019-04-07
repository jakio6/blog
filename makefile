
# first what need to be trans to html
markdownfile := $(wildcard ./*.md)

# 但是还是需要知道从是要从哪个文件生成的,还是得有个对应关系,这样一点用都没有啊
# basefile := $(foreach var,${markdownfile},$(notdir $(basename ${var})))
#
# 所以这种对应关系还是用文件系统来保存吧

# 目标文件应该是对应路径下的html目录下的
htmlfile := $(foreach var,${markdownfile},$(dir ${var})html/$(basename $(notdir ${var})).html)

# 规则应该怎么写呢 ?
#
# 命令行是有限制的啊可是..

.PHONY: index.html

index.html : ${htmlfile}
	@echo $@
	@cat info.html > $@ # 这个就不加到依赖了,烦啊
	@echo $^ | tr ' ' '\n' | sed 's/\(.*html\/\(.*\)\.html\)/<li><a href="\1">\2<\/a><\/li>/' >> $@

html:
	mkdir html

# 下面这个方式好像很不错,静态规则好像是
${htmlfile}: html/%.html:  %.md html
	@echo $@
	@pandoc $< -f gfm -t html -o $@ --metadata title=$*
