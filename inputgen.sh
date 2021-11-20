#!/bin/bash

declare -a ops=("xadd" "xsub" "xmul" "xdiv" "xmod" "xand" "xoor" "xxor" "xnot" "xshl" "xshr" "xeq" "xiszero" "xlt" "xgt")

lcs[0]=32
lcs[1]=16
lcs[2]=8
lcs[3]=4

for op in "${ops[@]}"
do

	lc_index=0
	
	# integer simd operations
	for (( lw=1; lw<=8; lw*=2 ))
	do
		for (( lc=2; lc<=lcs[lc_index]; lc*=2 ))
		do
		
		tot=$(( 3200000/lc ))
		echo "${op} for int, ${tot}, lw=${lw}, lc=${lc}"
		sh -c "./ethparser 0 ./ops/${op}/int/LW${lw}/ethRaw.txt ${tot} ./ops/${op}/int/LW${lw}/LC${lc}/ethSimd.txt > ../evmInputs/ops/${op}/int/LW${lw}/LC${lc}/ethSimd.txt"
		
		done
		(( lc_index++ ))
	done



	lc_index=2

	# floating simd operations
	for (( lw=4; lw<=8; lw*=2 ))
	do
		for (( lc=2; lc<=lcs[lc_index]; lc*=2 ))
		do
		
		tot=$(( 3200000/lc ))
		echo "${op} for floating, ${tot}, lw=${lw}, lc=${lc}"
		sh -c "./ethparser 0 ./ops/${op}/float/LW${lw}/ethRaw.txt ${tot} ./ops/${op}/float/LW${lw}/LC${lc}/ethSimd.txt > ../evmInputs/ops/${op}/float/LW${lw}/LC${lc}/ethSimd.txt"
		
		done
		(( lc_index++ ))
	done


	# integer scalar operations
	for (( lw=1; lw<=8; lw*=2 ))
	do


		echo "${op} for scalar int, 3200000, lw=${lw}"
		sh -c "./ethparser 3200000 ./ops/${op}/int/LW${lw}/ethRaw.txt 0 ./ops/${op}/int/LW${lw}/LC2/ethSimd.txt > ../evmInputs/ops/${op}/int/LW${lw}/ethRaw.txt"
		
	done

done

