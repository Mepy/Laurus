fn Int::from_str(str : String) -> Int {
	let mut n = 0 
	for c in str { 
		n = n * 10 + (c.to_int() - '0')
	}
	n
}