'''
Edwards25519 - The elliptic curve Edwards25519 is the twisted
Edwards curve defined over prime field GF(p) with p = 2^255 - 19
and parameters a = -1 and d = -121665/121666. This curve has
order h*n, where h = 8, and n is a prime number.

For this curve, a is a square in GF(p), whereas d is not. The
quadratic twist of this curve has order h_1⋅n_1 , where h_1 = 4,
and n_1 is a prime number.

This curve has domain parameters D = (p, h, n, Type, a, 1 d, G),
where the Type is “twisted Edwards curve,” and the other parameters
are defined as follows:    

(Source: NIST.SP.800-186 - Recommendations 
for Discrete Logarithm-based Cryptography: Elliptic Curve Domain Parameters)

The curve Edwards25519 is bi-rationally equivalent to the curve Curve25519. 
(as specified in NIST.SP.800-186 Section 3.2.2.1 and Appendix B.1)
'''

from math import log2
from util import hex_to_bin, sha512

################
## Paramaters ##
################
# Base field, GF(p)
p = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed
h = 8

# Group order
n = 2**252 + 0x14def9dea2f79cd65812631a5cf5d3ed

tr = (p+1) - h*n

# Curve constants
a = -1
d = 0x52036cee2b6ffe738cc740797779e89800700a4d4141d8ab75eb4dca135978a3


######################
## Special Elements ##
######################
# Generator point, G
Gx = 0x216936d3cd6e53fec0a4e231fdd6dc5c692cc7609525a7b2c9562d608f25d51a
Gy = 0x6666666666666666666666666666666666666666666666666666666666666658

G = (Gx, Gy)

# Identity element, e
e = (0, 1)
# Note: (0,1) is the identity element since for each point
#       P = (x,y) on the twisted Edwards curve E_{a,d} one has
#       P + (0, 1) = (x, y) + (0, 1) = (x, y) = P.


# Inverse element(s), p^{-1}
def inverse(p1):
    '''
    Find a point's inverse.
    
    For each point P = (x, y) on the twisted Edwards curve E_{A,B}, 
    the inverse point −P is the point (-x,y), and one has 
    P + (−P) = (0, 1). The point (0, −1) has order 2.
    '''
    return (-p1[0], p1[1])


###########################
## Operation / Group Law ##
###########################
def point_add(p1, p2):
    '''
    Group Law for twisted Edwards Curves
    (x3, y3) == (x1, y1) * (x2, y2) == p1 * p2

    TODO: write out the group law more
    '''
    denom = d*p1[0]*p2[0]*p1[1]*p2[1]
    return ( int((p1[0]*p2[1] + p1[1]*p2[0]) / (1 + denom)),
             int((p1[1]*p2[1] - a*p1[0]*p2[0]) / (1 - denom)) )


def proj_point_add(P, Q):
    '''
    Adding points using their projective coordinates.
    '''
    P = (P[0], P[1], P[0]*P[1])    # (x,y) --> (x/z, y/z, xy/z) for z = 1
    Q = (Q[0], Q[1], Q[0]*Q[1])

    A, B = (P[1]-P[0]) * (Q[1]-Q[0]) % p, (P[1]+P[0]) * (Q[1]+Q[0]) % p
    C, D = 2 * P[3] * Q[3] * d % p, 2 * P[2] * Q[2] % p
    E, F, G, H = B-A, D-C, D+C, B+A
    print (E*F, G*H, F*G, E*H)
    return (E*F, G*H, F*G, E*H)


def point_dbl(p1):
    '''
    Point Doubling
    '''
    return point_add(p1, p1)


def point_double(pt):
    '''
    Point Doubling using a formula derived from the Group Law

    (x,y) = ( (2 * x_1 * y_1) / (1 + d * x_1^2 * y_1^2),
              (y_1^2 - a * x_1^2) / ( 1 - d * x_1^2 * y_1^2
    '''
    denom = d * pt[0]**2 * pt[1]**2
    return ( int((2 * pt[0] * pt[1]) / (1 + denom)),
             int((pt[1]**2 - a * pt[0]**2) / (1 - denom)) )


def add_g_forever(k=0):
    '''
    (This is a tribute to a noble first attempt to 
    exponentiate a base many, many times.)
    
    Add the generator point to itself k times.
    
    Returns: [k]G
    '''
    g = G
    while k >= 1:
        point_add(g, G)
        k -= 1
    return g


def dbl_and_add_g(k=0):
    '''
    Double and Add, simple method

    Note: This method is vulnerable to timing analysis.
    '''
    bits = hex_to_bin(k) # bit vector (from LSB to MSB) representing s
    res = G
    i = len(bits) - 1
    while i >= 0:   # traverse from second MSB to LSB
        res = point_double(res) # double
        if bits[i] == '1':
            res = point_add(res, G) # add
        i = i - 1

    return res


def add_g(k=0):
    '''
    Double-and-Add via Montgomery ladder

    The Montgomery ladder approach computes the point in 
    a fixed number of operations. This can be beneficial 
    when timing, power consumption, or branch measurements 
    are exposed to an attacker.

    ***Potentially there is a side-channel here.***
    Yarom, Yuval; Benger, Naomi (2014). "Recovering OpenSSL ECDSA Nonces Using the FLUSH+RELOAD Cache Side-channel Attack". IACR Cryptology ePrint Archive.
    (see https://eprint.iacr.org/2014/140) 
    '''
    if k == 0:
        return G
    
    r0 = (0, 0)
    r1 = G
    exp = hex_to_bin(k)
    
    for b in exp:
        if b == '0':
            r1 = point_add(r0, r1)
            r0 = point_double(r0)
        else:
            r0 = point_add(r0, r1)
            r1 = point_double(r1)
                
    return r0


###############
## Functions ##
###############
def encode_point(self, P):
        """ Encodes a point P according to *draft_irtf-cfrg-eddsa-04*.

        Args:
            P: point to encode

        Returns:
           bytes : encoded point
        """
        size = self._coord_size()

        y = bytearray(P.y.to_bytes(size,'little'))
        if P.x&1:
            y[len(y)-1] |= 0x80
        return bytes(y)


def gen_signature(M, d, Q):
    '''
    Generate an EdDSA signature on message M and
    public-private keypair (d, Q).
    '''
    
    Hd = sha512(d)  # SHA-512(d = privkey)
    hdigest1 = Hd[0:63]    # hdigest1 = h_0 || h_{1}   || ... || h_{b-1}
    hdigest2 = Hd[64:128]  # hdigest2 = h_b || h_{b+1} || ... || h_{2b-1}

    r = int(sha512(hdigest2 + M), 16)

    print(r)

    # This is a hard problem. Use science.
    # rG = dbl_and_add_g(1)  # [r]G
    # print(rG)

    proj_point_add((0,1), (0,1))
    return hdigest1


###########
## Tests ##
###########
if __name__ == '__main__':
    # Test parameters
    assert p == 2**255 - 19
    assert h == 8
    assert n == 7237005577332262213973186563042994240857116359379907606001950938285454250989

    # tr (trace...?)
    assert tr == -221938542218978828286815502327069187962
    
    assert a == -1

    # d = -121665/121666
    assert d == 37095705934669439343138083508754565189542113879843219016388785533085940283555

    # Test the point at infinity
    # Gx
    assert Gx == 15112221349535400772501151409588531511454012693041857206046113283949847762202

    # Gy = 4/5
    assert Gy == 46316835694926478169428394003475163141307993866256225615783033603165251855960

    assert G == (Gx, Gy)

    # Test identity element
    assert e == (0,1)
    assert point_add((100,150), e)
    assert point_dbl(e) == e
    assert point_double(e) == e

    # Test inverse elements
    q = (0, -1)  # the point q := (0, -1) has order 2
                 # Therefore, it is its own inverse.
    assert point_double(q) == e

    # Test point operations    
    assert point_add(q, point_double(q)) == q

    # Test signature
    gen_signature('whatever', 1,0)
