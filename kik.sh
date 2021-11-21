#!/usr/bin/bash

board=('-' '-' '-' '-' '-' '-' '-' '-' '-')
end=0

display() {
	echo "BOARD"	>> game_board
	echo ${board[0]} ${board[1]} ${board[2]} >> game_board
	echo ${board[3]} ${board[4]} ${board[5]} >> game_board
	echo ${board[6]} ${board[7]} ${board[8]} >> game_board
	tail -n 4 game_board
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

move_player_1() {
	while true; do
		echo "$player_1! Enter a number of field."
		read field
		if [[ $field -lt 10 && $field -gt  0 ]] ; then	#sprawdza dostepnosc pola
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

move_player_2() {
	while true; do
		echo "$player_2! Enter a number of field."
		read field
		if [[ $field -lt 10 && $field -gt  0 ]] ; then
			if [[ ${board[$field-1]} == '-' ]] ; then
				board[$field-1]="o"
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
	     1 2 3 4 5 6 7 8 9)	#mozliwosci wygranej
	
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

save_info() {
		echo $player_1 >> game_board
		echo $player_2 >> game_board
		echo $mode >> game_board	
		echo $who_starts >> game_board	
}


new_game=1  #czy zaczynamy nowa gre
tie='0'			#zmienna kontroluajca remis

if [[ -e game_board && -n game_board ]]; then	#jesli wczesniejsza gra zostala przerwana
	length=$(cat game_board | wc -l)

	echo "Do you want to back to the last saved game? No - press \"0\", Yes - press \"1\""
	read reload
	if [[ $reload != 1 && $reload != 0 ]]; then		#walidacja zmiennej reload
		echo "Seriously? Say goodbye to your last game"
		rm game_board
	elif [[ $reload == 0 ]]; then
		rm game_board
	else
		new_game=0
		#zapis informacji z pliku game_board
		player_1=$(sed -n '1p' game_board)
		player_2=$(sed -n '2p' game_board)
		mode=$(sed -n '3p' game_board)
		who_starts=$(sed -n '4p' game_board)
		
		last_saved=$(tail -n 3 game_board | tr '\n' ' ')
		read -a board <<< $last_saved
		
		count_empty=0
		for index in {1..9}; do
			if [[ ${board[index]} == '-' ]];then
				count_empty=$(($count_empty+1))
			fi
		done
		round=$((8-$count_empty))	#zapisana liczba minionych rund
		
	fi
fi

if [[ $new_game == 1 ]]; then
	
	touch game_board
	chmod 777 game_board
	player_1='You'
	player_2='Computer'
	
	round=0			#licznik rund

	echo "Select the game mode. With computer - press \"0\", with human (if you found someone)- press \"1\""
	read mode			#0: gra z komputerm, 1: z czlowiekiem

	if [[ $mode != 1 && $mode != 0 ]]; then		#walidacja zmiennej mode
		echo "Seriously? So you'll play with computer"
		mode=0
	elif [[ $mode == 1 ]]; then			#gra z innym graczem
		echo "Enter the first player's name"
		read pl_1
		player_1=$pl_1
		echo "Enter the second player's name"
		read pl_2
		player_2=$pl_2
	fi

	 
	echo "Who starts? $player_1 - press \"0\", $player_2 - press \"1\""	
	read who_starts		#0: gracz 1, 1: gracz 2
	if [[ $player != 1 && $player != 0 ]]; then
		echo "Seriously? So $player_2 will start the game"	#walidacja zmiennej who_starts
		who_starts=1
	fi
fi

save_info


while [[ $end == 0 ]]; do
	if [[ $round == 9  ]]; then	#koneic wolnych ruchow
		tie='1'
		break
	fi
	display
	if [[ $(($round % 2)) == $who_starts  ]]; then
		move_player_1
	else 
		if [[ $mode == 0 ]]; then
			response
		else
			move_player_2
		fi
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
	if [[ $(($[$round-$who_starts] % 2)) != 0 ]]; then
		echo "$player_1"	
	else
		echo "$player_2"
	fi
fi

display
rm game_board
