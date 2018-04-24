# Copyright 2016 Transwarp Inc. All rights reserved.

local app = import "../app.libsonnet";
local s = [
  # case 0: E -> null
  ["", null],  #0
  # case 1: E -> '\' | ws | pc | E
  # 1.0: E -> '\'
  ["\\", null],  #1
  [" \\ ", null],  #2
  [" \\ \\", null],  #3
  ["\\ \\ ", null],  #4
  ["\\ \\", null],  #5
  [" \\ \\ ", null],  #6
  ["\\\\", ["\\"]],  #7
  ["\\\\\\", ["\\\\"]],  #8
  ["", null],  #9
  #10
  # 1.1: E -> '\' | ws
  [" ", null],  #0
  ["\n", null],  #1
  ["\\\n", null],  #2
  ["\\\n\\", null],  #3
  ["\n \\ \\ \n", null],  #4
  ["\n\n\\\n\\ \n", null],  #5
  ["\r", null],  #6
  ["\r ", null],  #7
  ["\\ \r \\", null],  #8
  [" \r ", null],  #9
  #20
  ["\r\n", null],  #0
  ["\r\\\n\r", null],  #1
  ["\r\n\r\\", null],  #2
  ["\\\r\n\r\\", null],  #3
  ["\\t\\ \r \\\n\r\\", null],  #4
  ["\t", null],  #5
  ["\\\n\r\t", null],  #6
  ["\\ \n \r \t", null],  #7
  ["\\ \n\\ \\\r \t", null],  #8
  ["", null],  #9
  #30
  # 1.2: E -> '\' | ws | pc | E
  ["a", ["a"]],  #0
  ["\na", ["a"]],  #1
  ["a\r", ["a"]],  #2
  ["cd dir", ["cd", "dir"]],  #3
  ["\\tcd\\ \r \\dir\n\r\\", ["cd", "dir"]],  #4
  ["/sbin/ifconfig eth0 | grep wyc", ["/sbin/ifconfig", "eth0", "|", "grep", "wyc"]],  #5
  ["/sbin/ifconfig eth0 | grep w\ty\nc", ["/sbin/ifconfig", "eth0", "|", "grep", "w", "y", "c"]],  #6
  ["", null],  #7
  ["", null],  #8
  ["", null],  #9
  #40
  # case 2: E -> 'S'
  ["''", null],  #0
  ["' '", [" "]],  #1
  ["\\'\\'", null],  #2
  ["\\'a\\'", ["a"]],  #3
  ["\\'a b\\'", ["a b"]],  #4
  ["\\' a b \\'", [" a b "]],  #5
  ["\\' abc\n bd\tef \\' \\p''", [" abc\n bd\tef ", "p"]],  #6
  ["''a", ["a"]],  #7
  ["bc''a", ["bca"]],  #8
  ["bc'def'a", ["bcdefa"]],  #9
  #50
  ["bc 'def'a", ["bc", "defa"]],  #0
  ["bc 'def' a", ["bc", "def", "a"]],  #1
  ["bc 'def pqr' a", ["bc", "def pqr", "a"]],  #2
  ["nl /etc/passwd | sed -n '5,7p'", ["nl", "/etc/passwd", "|", "sed", "-n", "5,7p"]],  #3
  ["nl /etc/passwd | sed -n '/bash/{s/bash/blueshell/;p;q}' ", ["nl", "/etc/passwd", "|", "sed", "-n", "/bash/{s/bash/blueshell/;p;q}"]],  #4
  ["", null],  #5
  ["", null],  #6
  ["", null],  #7
  ["", null],  #8
  ["", null],  #9
  #60
  # case 3: E -> "D"
  ['"\"\""', null],  #0
  ['""', null],  #1
  ['a"b"cdf', ["abcdf"]],  #2
  ['a "b" c', ["a", "b", "c"]],  #3
  ['a "b d" c', ["a", "b d", "c"]],  #4
  ['a " b d " c', ["a", " b d ", "c"]],  #5
  ['a\t" b d "\nc', ["a", " b d ", "c"]],  #6
  ['a\t" \rb \nd\t "\nc', ["a", " \rb \nd\t ", "c"]],  #7
  ['/sbin/ifconfig eth0 | grep "inet addr" | sed "s/^.*addr://g"', ["/sbin/ifconfig", "eth0", "|", "grep", "inet addr", "|", "sed", "s/^.*addr://g"]],  #8
  ["", null],  #9
  #70
  # case 4: E -> `B`
  ["``", null],  #0
  ["\\`\\`", null],  #1
  ["\\`a\\`", ["a"]],  #2
  ["\\`a b\\`", ["a b"]],  #3
  ["c\\`a b\\`", ["ca b"]],  #4
  ["c\\`a b\\`d", ["ca bd"]],  #5
  ["c\\`a b\\` d", ["ca b", "d"]],  #6
  ["c \\`a b\\` d", ["c", "a b", "d"]],  #7
  ["c efg\\`a b\\` d", ["c", "efga b", "d"]],  #8
  ["echo 'The testvalue is $testvalue'\\echo The date is `date`", ["echo", "The testvalue is $testvalueecho", "The", "date", "is", "date"]],  #9
  #80
  # case 5: E -> (L)
  ["()", ["()"]],  #0
  ["(\"\")", ["(\"\")"]],  #1
  ['("")', ["(\"\")"]],  #2
  ["a()b", ["a()b"]],  #3
  ["a(c)b", ["a(c)b"]],  #4
  ["a( c d )b", ["a( c d )b"]],  #5
  ["a( c d ) b", ["a( c d )", "b"]],  #6
  ["echo $(( a + b*c))", ["echo", "$(( a + b*c))"]],  #7
  ["echo $(((a*b)/c))", ["echo", "$(((a*b)/c))"]],  #8
  ["", null],  #9
  #90
  # case 6: E -> {C}
  ["{}", ["{}"]],  #0
  ["{()}", ["{()}"]],  #1
  ["a{}b", ["a{}b"]],  #2
  ["a{c}b", ["a{c}b"]],  #3
  ["\\{\\}", ["{}"]],  #4
  ["", null],  #5
  ["", null],  #6
  ["", null],  #7
  ["", null],  #8
  ["", null],  #9
  #100
  # case 7: ... reserve add more tests
  [" $( this) should {  } ` ` \" \" ' separated' !", ["$( this)", "should", "{  }", " ", " ", " separated", "!"]],  #0
  ["null->\"\"<-null", ["null-><-null"]],  #1
  ["null->\"\"''``<-null", ["null-><-null"]],  #2
  ['nginx -g "daemon off;"', ["nginx", "-g", "daemon off;"]],  #3
  ["", null],  #4
  ["", null],  #5
  ["", null],  #6
  ["", null],  #7
  ["", null],  #8
  ["", null],  #9
  #110
];

# case 0
# case 1
# 1.0
std.assertEqual(app.shlex(s[0][0]), s[0][1]) &&
std.assertEqual(app.shlex(s[1][0]), s[1][1]) &&
std.assertEqual(app.shlex(s[2][0]), s[2][1]) &&
std.assertEqual(app.shlex(s[3][0]), s[3][1]) &&
std.assertEqual(app.shlex(s[4][0]), s[4][1]) &&
std.assertEqual(app.shlex(s[5][0]), s[5][1]) &&
std.assertEqual(app.shlex(s[6][0]), s[6][1]) &&
std.assertEqual(app.shlex(s[7][0]), s[7][1]) &&
std.assertEqual(app.shlex(s[8][0]), s[8][1]) &&
std.assertEqual(app.shlex(s[9][0]), s[9][1]) &&
# 1.1
std.assertEqual(app.shlex(s[10][0]), s[10][1]) &&
std.assertEqual(app.shlex(s[11][0]), s[11][1]) &&
std.assertEqual(app.shlex(s[12][0]), s[12][1]) &&
std.assertEqual(app.shlex(s[13][0]), s[13][1]) &&
std.assertEqual(app.shlex(s[14][0]), s[14][1]) &&
std.assertEqual(app.shlex(s[15][0]), s[15][1]) &&
std.assertEqual(app.shlex(s[16][0]), s[16][1]) &&
std.assertEqual(app.shlex(s[17][0]), s[17][1]) &&
std.assertEqual(app.shlex(s[18][0]), s[18][1]) &&
std.assertEqual(app.shlex(s[19][0]), s[19][1]) &&

std.assertEqual(app.shlex(s[20][0]), s[20][1]) &&
std.assertEqual(app.shlex(s[21][0]), s[21][1]) &&
std.assertEqual(app.shlex(s[22][0]), s[22][1]) &&
std.assertEqual(app.shlex(s[23][0]), s[23][1]) &&
std.assertEqual(app.shlex(s[24][0]), s[24][1]) &&
std.assertEqual(app.shlex(s[25][0]), s[25][1]) &&
std.assertEqual(app.shlex(s[26][0]), s[26][1]) &&
std.assertEqual(app.shlex(s[27][0]), s[27][1]) &&
std.assertEqual(app.shlex(s[28][0]), s[28][1]) &&
std.assertEqual(app.shlex(s[29][0]), s[29][1]) &&
# 1.2
std.assertEqual(app.shlex(s[30][0]), s[30][1]) &&
std.assertEqual(app.shlex(s[31][0]), s[31][1]) &&
std.assertEqual(app.shlex(s[32][0]), s[32][1]) &&
std.assertEqual(app.shlex(s[33][0]), s[33][1]) &&
std.assertEqual(app.shlex(s[34][0]), s[34][1]) &&
std.assertEqual(app.shlex(s[35][0]), s[35][1]) &&
std.assertEqual(app.shlex(s[36][0]), s[36][1]) &&
std.assertEqual(app.shlex(s[37][0]), s[37][1]) &&
std.assertEqual(app.shlex(s[38][0]), s[38][1]) &&
std.assertEqual(app.shlex(s[39][0]), s[39][1]) &&
# case 2: E -> 'S'
std.assertEqual(app.shlex(s[40][0]), s[40][1]) &&
std.assertEqual(app.shlex(s[41][0]), s[41][1]) &&
std.assertEqual(app.shlex(s[42][0]), s[42][1]) &&
std.assertEqual(app.shlex(s[43][0]), s[43][1]) &&
std.assertEqual(app.shlex(s[44][0]), s[44][1]) &&
std.assertEqual(app.shlex(s[45][0]), s[45][1]) &&
std.assertEqual(app.shlex(s[46][0]), s[46][1]) &&
std.assertEqual(app.shlex(s[47][0]), s[47][1]) &&
std.assertEqual(app.shlex(s[48][0]), s[48][1]) &&
std.assertEqual(app.shlex(s[49][0]), s[49][1]) &&

std.assertEqual(app.shlex(s[50][0]), s[50][1]) &&
std.assertEqual(app.shlex(s[51][0]), s[51][1]) &&
std.assertEqual(app.shlex(s[52][0]), s[52][1]) &&
std.assertEqual(app.shlex(s[53][0]), s[53][1]) &&
std.assertEqual(app.shlex(s[54][0]), s[54][1]) &&
std.assertEqual(app.shlex(s[55][0]), s[55][1]) &&
std.assertEqual(app.shlex(s[56][0]), s[56][1]) &&
std.assertEqual(app.shlex(s[57][0]), s[57][1]) &&
std.assertEqual(app.shlex(s[58][0]), s[58][1]) &&
std.assertEqual(app.shlex(s[59][0]), s[59][1]) &&
# case 3: E -> "D"
std.assertEqual(app.shlex(s[60][0]), s[60][1]) &&
std.assertEqual(app.shlex(s[61][0]), s[61][1]) &&
std.assertEqual(app.shlex(s[62][0]), s[62][1]) &&
std.assertEqual(app.shlex(s[63][0]), s[63][1]) &&
std.assertEqual(app.shlex(s[64][0]), s[64][1]) &&
std.assertEqual(app.shlex(s[65][0]), s[65][1]) &&
std.assertEqual(app.shlex(s[66][0]), s[66][1]) &&
std.assertEqual(app.shlex(s[67][0]), s[67][1]) &&
std.assertEqual(app.shlex(s[68][0]), s[68][1]) &&
std.assertEqual(app.shlex(s[69][0]), s[69][1]) &&
# case 4: E -> `B`
std.assertEqual(app.shlex(s[70][0]), s[70][1]) &&
std.assertEqual(app.shlex(s[71][0]), s[71][1]) &&
std.assertEqual(app.shlex(s[72][0]), s[72][1]) &&
std.assertEqual(app.shlex(s[73][0]), s[73][1]) &&
std.assertEqual(app.shlex(s[74][0]), s[74][1]) &&
std.assertEqual(app.shlex(s[75][0]), s[75][1]) &&
std.assertEqual(app.shlex(s[76][0]), s[76][1]) &&
std.assertEqual(app.shlex(s[77][0]), s[77][1]) &&
std.assertEqual(app.shlex(s[78][0]), s[78][1]) &&
std.assertEqual(app.shlex(s[79][0]), s[79][1]) &&
# case 5: E -> (L)
std.assertEqual(app.shlex(s[80][0]), s[80][1]) &&
std.assertEqual(app.shlex(s[81][0]), s[81][1]) &&
std.assertEqual(app.shlex(s[82][0]), s[82][1]) &&
std.assertEqual(app.shlex(s[83][0]), s[83][1]) &&
std.assertEqual(app.shlex(s[84][0]), s[84][1]) &&
std.assertEqual(app.shlex(s[85][0]), s[85][1]) &&
std.assertEqual(app.shlex(s[86][0]), s[86][1]) &&
std.assertEqual(app.shlex(s[87][0]), s[87][1]) &&
std.assertEqual(app.shlex(s[88][0]), s[88][1]) &&
std.assertEqual(app.shlex(s[89][0]), s[89][1]) &&
# case 6: E -> {C}
std.assertEqual(app.shlex(s[90][0]), s[90][1]) &&
std.assertEqual(app.shlex(s[91][0]), s[91][1]) &&
std.assertEqual(app.shlex(s[92][0]), s[92][1]) &&
std.assertEqual(app.shlex(s[93][0]), s[93][1]) &&
std.assertEqual(app.shlex(s[94][0]), s[94][1]) &&
std.assertEqual(app.shlex(s[95][0]), s[95][1]) &&
std.assertEqual(app.shlex(s[96][0]), s[96][1]) &&
std.assertEqual(app.shlex(s[97][0]), s[97][1]) &&
std.assertEqual(app.shlex(s[98][0]), s[98][1]) &&
std.assertEqual(app.shlex(s[99][0]), s[99][1]) &&
# case 7: ... reserve add more tests
std.assertEqual(app.shlex(s[100][0]), s[100][1]) &&
std.assertEqual(app.shlex(s[101][0]), s[101][1]) &&
std.assertEqual(app.shlex(s[102][0]), s[102][1]) &&
std.assertEqual(app.shlex(s[103][0]), s[103][1]) &&
std.assertEqual(app.shlex(s[104][0]), s[104][1]) &&
std.assertEqual(app.shlex(s[105][0]), s[105][1]) &&
std.assertEqual(app.shlex(s[106][0]), s[106][1]) &&
std.assertEqual(app.shlex(s[107][0]), s[107][1]) &&
std.assertEqual(app.shlex(s[108][0]), s[108][1]) &&
std.assertEqual(app.shlex(s[109][0]), s[109][1]) &&
true
