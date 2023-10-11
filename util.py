'''
Utility functions for doing various small tasks related to general cryptography 
(hashing, random number generation, etc.), maths (gcd, lcd, ..., gcf, ...), etc.
'''

import hashlib

def sha512(data):
    '''
    Helper for hashing w/ SHA-512.

    Returns: hex digest of SHA-512(data)
    '''
    H = hashlib.sha512()
    H.update(b'{data}')  # ensure M is bytes
    return H.hexdigest()


def hex_to_bin(h):
    '''
    Convert a hexadecimal number to binary, 
    bit-addressable representation.
    We choose to lob off the '0b' at the 
    beginning of the string.
    
    Returns: binary string, a bit-addressable representation of h
    '''
    return bin(h)[2:]


###########
## Tests ##
###########
if __name__ == '__main__':

    # Test hex -> binary 
    b = hex_to_bin(0xdeadbeef)
    assert b == '11011110101011011011111011101111'
    assert b[0:2] != '0b'   # look to first elements 
    assert b[-1] in ['0', '1']  # look to last elements
    print('0xdeadbeef')
    for i in range(len(b)):
        print(b[i], end='')
        
    
