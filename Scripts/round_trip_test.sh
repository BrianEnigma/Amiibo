#!/bin/bash

./txt2bin.rb ../Images/Zelda.txt ../Images/test.bin
./printbin.rb ../Images/test.bin | sed 's/    #.*//' > ../Images/test.txt

#bcompare ../Images/Zelda.txt ../Images/test.txt
diff ../Images/Zelda.txt ../Images/test.txt

