#!/usr/bin/python

def factorization(n):
	res = 1
	d = 2
	while n != 1:
		if n % d == 0:
			res *= d
			while n % d == 0:
				n /= d
		d += 1
	return res

a = 1
while 1:
	n = factorization(a)
	if n**n % a != 0:
		if n % 2 == 0: 
			n *= 2
		else:
			if n % 3 == 0: 
				n *= 3
		if n**n % a != 0:
			print str(a)+" (n="+str(n)+")"
	a += 1

