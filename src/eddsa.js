const elliptic = require('elliptic');
const ed25519 = new require('elliptic').eddsa('ed25519');
const BN = require('bn.js');

function printPointInfo(desc, P) {
  console.log(`${desc}: hex:     ` + elliptic.utils.toHex(ed25519.encodePoint(P)));
  console.log(`${desc}: x-coord: ` + P.getX());
  console.log(`${desc}: y-coord: ` + P.getY());
  console.log();
}

let G = ed25519.curve.g;

let a = '12581e70a192aeb9ac1411b36d11fc06393db55998190491c063807a6b4d730d';
let b = '0c2340b974bebfb9cb3f14e991bca432b57fb33f7c4d79e15f64209076afcd00';

let aG = G.mul(elliptic.utils.intFromLE(a));
let bG = G.mul(elliptic.utils.intFromLE(b));

printPointInfo('G', G);
printPointInfo('2G', G.mul(new BN(2)));
printPointInfo('3G', G.mul(new BN(3)));
printPointInfo('4G', G.mul(new BN(4)));
printPointInfo('5G', G.mul(new BN(5)));
printPointInfo('aG', aG);
printPointInfo('bG', bG);
