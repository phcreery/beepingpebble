module keyboard

import os

pub fn optimise_term () {
	os.system("/bin/stty -ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr -icrnl -ixon -ixoff -icanon -opost -isig -iuclc -ixany -imaxbel -xcase -echo")
	os.system("tput civis")
}

pub fn restore_term () {
	os.system("/bin/stty -raw echo")
	os.system("tput cnorm")
}