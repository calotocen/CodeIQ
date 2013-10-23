/**********************************************************/
/*                                                        */
/* 「JS：素数の数を数えてください」の回答(コメント加筆有) */
/*                                                        */
/**********************************************************/

// 実行例：
//   > cscript //Nologo printnumber.js
//   10
//   4
//   ^Z
//   > 

// 標準入力から数値を読み込み，
// その数値よりも小さい素数の数を標準出力へ書き出す。
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

// number が素数であるか判定する。
// 素数である場合は true，そうでない場合は false を返す。
function isPrimeNumber(number) {
	// 1 は素数ではない。
	if (number == 1) {
		return false;
	}
	
	// number を割り切れる整数があるか確認する。
	// 割り切れる整数がない場合，number は素数である。
	// なお，number を割り切れる可能性のある整数は，
	// 2 ～ (number / 2) (小数点以下切り捨て) である。
	for (var n = 2; n <= number / 2; ++n) {
		var remnant = number % n;
		if (remnant == 0) {
			return false;
		}
	}
	
	return true;
}
