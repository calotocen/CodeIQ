/**********************************************************/
/*                                                        */
/* �uJS�F�f���̐��𐔂��Ă��������v�̉�(�R�����g���M�L) */
/*                                                        */
/**********************************************************/

// ���s��F
//   > cscript //Nologo printnumber.js
//   10
//   4
//   ^Z
//   > 

// �W�����͂��琔�l��ǂݍ��݁C
// ���̐��l�����������f���̐���W���o�͂֏����o���B
while (!WScript.StdIn.AtEndOfStream) {
	var number = WScript.StdIn.ReadLine()
	
	var count = 0;
	for (var n = 1; n < number; ++n) {
		if (isPrimeNumber(n)) {
			++count;
		}
	}
	
	WScript.Echo(count);
}

// number ���f���ł��邩���肷��B
// �f���ł���ꍇ�� true�C�����łȂ��ꍇ�� false ��Ԃ��B
function isPrimeNumber(number) {
	// 1 �͑f���ł͂Ȃ��B
	if (number == 1) {
		return false;
	}
	
	// number ������؂�鐮�������邩�m�F����B
	// ����؂�鐮�����Ȃ��ꍇ�Cnumber �͑f���ł���B
	// �Ȃ��Cnumber ������؂��\���̂��鐮���́C
	// 2 �` (number / 2) (�����_�ȉ��؂�̂�) �ł���B
	for (var n = 2; n <= number / 2; ++n) {
		var remnant = number % n;
		if (remnant == 0) {
			return false;
		}
	}
	
	return true;
}
