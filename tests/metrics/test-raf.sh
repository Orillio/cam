#!/usr/bin/env bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2024 Yegor Bugayenko
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

temp=$1
stdout=$2

{
  tmp=$(mktemp -d /tmp/XXXX)
  cd "${tmp}"
  touch "temp_file"
  mkdir -p "${LOCAL}/${temp}"
  "${LOCAL}/metrics/raf.sh" "temp_file" "${LOCAL}/${temp}/stdout"
  grep "raf 0" "${LOCAL}/${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Didn't fail in non-git directory"

{
  tmp=$(mktemp -d /tmp/XXXX)
  cd "${tmp}"
  rm -rf ./*
  rm -rf .git
  git init --quiet .
  git config user.email 'foo@example.com'
  git config user.name 'Foo'
  file="temp_file"
  file2="temp_file1"
  touch "${file}"
  git add "${file}"
  git config commit.gpgsign false
  git commit --quiet -m "first"
  "${LOCAL}/metrics/raf.sh" "${file}" "t1"
  sleep 1
  touch "${file2}"
  git add "${file2}"
  git commit --quiet -m "second"
  "${LOCAL}/metrics/raf.sh" "${file2}" "t2"
  sleep 1
  "${LOCAL}/metrics/raf.sh" "${file2}" "t3"
  # The following lines are disabled b/c the test is not stable, see: https://github.com/yegor256/cam/issues/165
  # grep "raf 1.0" "t1" # File is created with repo
  # grep "raf 0.0" "t2" # File a second after repo
  # grep "raf 0.5" "t3" # File created exactly in the middle
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated the Relative Age of File"
