#!/bin/bash

for htmlfile in `ls ../html/*.html | sed 's/^.//'` ; do
	echo "<li><a href=\"$htmlfile\">$htmlfile</a></li>"
done > ../index.html
