#!/bin/sh

wget -c https://raw.githubusercontent.com/elorimer/droid99/master/assets/994AROM.BIN
wget -c https://raw.githubusercontent.com/elorimer/droid99/master/assets/994AGROM.BIN

python3 ../create-mem-from-bin.py 994AROM.BIN  994arom.mem
python3 ../create-mem-from-bin.py 994AGROM.BIN 994agrom.mem
