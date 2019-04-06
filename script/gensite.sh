#!/bin/bash

for markdownfile in `ls ../*.md`;do
	base=`echo $markdownfile | sed 's/\.\.\/\(.*\).md/\1/'`
	pandoc $markdownfile -f gfm -t html -o ../html/$base.html -H header.html --metadata title=$base
done
