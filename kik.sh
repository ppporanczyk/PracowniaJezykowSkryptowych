#!/usr/bin/bash

board=('-' '-' '-' '-' '-' '-' '-' '-' '-')
end=0

display() {
	echo "BOARD"
	echo ${board[0]} ${board[1]} ${board[2]}
	echo ${board[3]} ${board[4]} ${board[5]}
	echo ${board[6]} ${board[7]} ${board[8]}
}

response() {
	while true ; do
		rand_field=$((1+$RANDOM % 10))
        	if [[ ${board[rand_field-1]} == "-" ]]; then
                	board[rand_field-1]="o"
			break
        	fi	
	done	
}

move() {
	while true; do
		echo "Enter a number of field."
		read field
		if [[ $field -lt 10 && $field -gt  0 ]] ; then
			if [[ ${board[$field-1]} == '-' ]] ; then
				board[$field-1]="x"
				break
			else
				echo "Taken. Try again."
			fi 		
		else
			echo "Press from 1 to 9"
			continue
		fi
	done
}

check() {
	arr=(1 5 9 
	     3 5 7 
	     1 4 7 2 5 8 3 6 9
	     1 2 3 4 5 6 7 8 9)
	
	for i in {0..7}; do
		index_1=${arr[3*$i]}
		index_2=${arr[3*$i+1]}
		index_3=${arr[3*$i+2]}
		if [[ ${board[$index_1-1]} == ${board[$index_2-1]} && ${board[$index_2-1]} == ${board[$index_3-1]} && ${board[$index_2-1]} != '-' ]]; then
			end=$(($end+1))
			break
		fi
	done	
	
}

tie='0'
round=0
echo "Who starts? You - press \"0\", computer - press \"1"\"
read player
if [[ $player -gt 1 || $player -lt 0 ]]; then
	echo "Seriously? So I'll start the game"
	player=1
fi
while [[ $end == 0 ]] ; do
	if [[ $round == 9  ]] ; then
		tie='1'
		break
	fi
	display
	if [[ $(($round % 2)) == $player ]]; then
		move
	else
		response
	fi
	if [[ $round -gt 3 ]]; then
		check
	fi
	round=$(($round+1))
	
done

if [[ tie -eq '1' ]]; then
	echo "Tie!"
else
	echo "The winner is..."
	if [[ $(($[$round-$player] % 2)) != 0 ]]; then
		echo "Player!!!"	
	else
		echo "Computer!!!"
	fi
fi
display
