#!/bin/bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2022 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
set -e
set -o pipefail

rm -f "${TARGET}/temp/list-of-metrics.tex"

for m in $(ls "${HOME}/metrics/"); do
    echo "class Foo {}" > "${TARGET}/temp/foo.java"
    rm -f "${TARGET}/temp/foo.${m}.m"
    "${HOME}/metrics/${m}" "${TARGET}/temp/foo.java" "${TARGET}/temp/foo.${m}.m"
    awk '{ s= "\\item\\ff{" $1 "}: "; for (i = 3; i <= NF; i++) s = s $i " "; print s; }' < "${TARGET}/temp/foo.${m}.m" >> "${TARGET}/temp/list-of-metrics.tex"
    echo "$(cat ${TARGET}/temp/foo.${m}.m | wc -l) metrics from ${m}"
done

# It's important to make sure the path is absolute, for LaTeX
t="$(realpath "${TARGET}")"

tmp="${t}/temp/pdf-report"
if [ -e "${tmp}" ]; then
    echo "Temporary directory for PDF report building already exists: '${tmp}'"
    latexmk -cd -C "${tmp}/report.tex"
    cp -r "${HOME}"/tex "${tmp}"
else
    cp -r "${HOME}/tex" "${tmp}"
fi

pdf="${tmp}/report.pdf"
if [ -e "${pdf}" ]; then
    echo "The PDF report already exists: '${pdf}'"
    exit
fi

TARGET="${t}" latexmk -pdf -r "${tmp}/.latexmkrc" -quiet -cd "${tmp}/report.tex"
mv "${pdf}" "${t}/report.pdf"
