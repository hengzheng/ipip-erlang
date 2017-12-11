# About ipip db
| data offset | ip first section index   |              ipindex                     | data |  
|  4 bytes    |     256 * 4 bytes        |          offset - 1028 bytes             |------|  
|-------------| bits offset for ipindex  |4bytes ip |3 bytes offset|1 byte date len |------|  
|-------------|--------------------------|--------- | point to data|----------------|------|  
| big-endian  |     little-endian        |big-endian|little-endian | big-endian     |------|  
Ip data: Counter\tProvine\tCity\t  
step: find ip {A,B,C,D} in Data  
0 Longip = (A bsl 24) bor (B bsl 16) bor (C bsl 8) bor D.  
1 calc data offset <<Offset:4/binary, IpFirstIndex:256*4/binary, Rest/binary>> = Data;  
2 ip first section offset <<_:A*4/binary, Start:32/little, _/binary>> = IpFirstIndex;  
3 ipindex start from Start\*8 bytes to Offset - 1028 bytes in Rest <<IpIndex:Offset - 1028/binary, _/binary>> = Rest;  
4 the first one Index and Len when Ip >= LongIp is the target <<_:Start*8/binary, Ip:4/binary, Index:24/little, Len, _/binary>> = IpIndex;  
5 resust <<_:Offset + Index - 1024/binary, Resut:Len/binary, _/binary>> = Data.  

# ipip-erlang
Erlang lib for 17monipdb.dat(http://www.ipip.net/download.html)  
```
find(Ip) -> {ok, Country, Provine, City} | false
    Types:
        Ip = binary()|string()|tuple()
        Country = binary()
        Provine = binary()
        City = binary()
Return location info of Ip which is IPv4 format if it existes, or 'false'.
```

# How To Use
```shell
$ make   
$ erl -pa ebin   
1> ipip:test("219.137.144.1").  
Ip:"219.137.144.1" -> Country: 中国 Province: 广东 City: 广州  
ok

2> ipip:find("219.137.144.1").  
{ok, <<228,184,173,229,155,189>>, <<229,185,191,228,184,156>>, <<229,185,191,229,183,158>>}
```
# Thank
[erlang-ip](https://github.com/kqqsysu/erlang-ip)
