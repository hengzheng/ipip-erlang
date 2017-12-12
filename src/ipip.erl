%%%------------------------------------------------------------------------
%%% @author : zhengheng
%%% @date   : 2017.11.23
%%% @desc   : ipip.net数据17monip.dat解析
%% ------------- DAT struct -----------------------------------------------
%%
%% 1| 4 bytes 数据偏移 DataOffset | 1,2,3部分的长度
%% 2| 256 * 4 ip首位对应的index 偏移 |
%%      每个index 指向3部分的ipindex(8 bytes)数据:
%%      4 bytes Ip, 3 bytes offSet(指向4部分的数据偏移), 1 byte data len
%% 3| DataOffset - 1028 ipindex数据 |
%% 4| Data Address Info ip数据|
%%
%% --------------------------------------------------------------------------
-module(ipip).

-define(IP_DB_DAT_FILE,"./priv/17monipdb.dat").

-export([test/1, find/1]).

%% 测试
test(Ip) ->
    case find(Ip) of
        {ok, Country, Province, City} ->
            io:format("Ip:~p -> Country: ~ts Province: ~ts City: ~ts ~n", [Ip, Country, Province, City]);
        false ->
            io:format("Ip:~p not in lib~n", [Ip])
    end.

%% 查找ip对应的location
find(<<A,B,C,D>>) ->
    find({A,B,C,D});
find(Ip) when is_binary(Ip) ->
    case binary:split(Ip, <<".">>, [global]) of
        [_,_,_,_] = L ->
            find(L);
        _ ->
            false
    end;
find([A,B,C,D]) ->
    find({to_integer(A),to_integer(B),to_integer(C),to_integer(D)});
find(Ip) when is_list(Ip)  ->
    case string:tokens(Ip, ".") of
        [_,_,_,_] = L ->
            find(L);
        _ ->
            false
    end;
find({_,_,_,_} = Ip) ->
    find(Ip,?IP_DB_DAT_FILE);
find(_) ->
    false.

find({A,_B,_C,_D} = Ip, DbFile) ->

    % 读文件
    {ok,FileBin} = file:read_file(DbFile),

    % 取出偏移量
    <<OffsetLen:4/binary, FirstIpBin:1024/binary, DataBin/binary>> = FileBin,

    % 分离ipindex数据和说明数据
    IpDataNum = OffsetLen - 1028,
    <<IpData:IpDataNum/binary, _/binary>> = DataBin,

    % 第一段ip的偏移量
    FirstIpOffset = A * 4,

    % 此ip的ipindex的开始
    <<_:FirstIpOffset/binary, FirstIpIndex:32/little, _/binary>> = FirstIpBin,
    StartIpIndex = FirstIpIndex * 8,

    % ipindex数据
    <<_:StartIpIndex/binary, IpIndexData/binary>> = IpData,

    % 查找数据
    LongIp = ntohl(Ip),
    case find_data_index(IpIndexData, LongIp, false) of
        {ok, DataOffset, DataLen} ->
            Offset = OffsetLen + DataOffset - 1024,
            <<_:Offset/binary, IpComment:DataLen/binary, _/binary>> = FileBin,
            % IpComment格式：国家   省份    城市(中间是tab分隔)
            [Country, Province, City|_] = binary:split(IpComment, <<"\t">>, [global]),
            {ok, Country, Province, City};
        false -> false
    end.

%% 二分查找
find_data_index(<<DataLongIp:32, DataOffset:24/little, DataLen>>, LongIp, Ret) ->
    if  DataLongIp >= LongIp ->
            {ok, DataOffset, DataLen};
        true ->
            Ret
    end;
find_data_index(Data, LongIp, Ret) ->
    MidOffset = size(Data) div 8 div 2 * 8,
    case Data of
        <<Head:MidOffset/binary, IpInfo:8/binary, Rest/binary>> ->
            <<DataLongIp:32, DataOffset:24/little, DataLen>> = IpInfo,
            if  DataLongIp < LongIp ->
                    find_data_index(Rest, LongIp, Ret);
                true -> % 有满足的先记录，但不一定是最接近的
                    find_data_index(Head, LongIp, {ok, DataOffset, DataLen})
            end;
        _ ->
            Ret
    end.
%% 按顺序查找
%find_data_index(<<DataLongIp:32, DataOffset:24/little, DataLen, Rest/binary>>, LongIp) ->
%    if  DataLongIp < LongIp ->
%            find_data_index(Rest, LongIp);
%        true ->
%            {ok, DataOffset, DataLen}
%    end;
%find_data_index(_, _) ->
%    false.

%% 转长ip
ntohl({A,B,C,D}) ->
    (A bsl 24) bor (B bsl 16) bor (C bsl 8) bor D.

%% 转整数
to_integer(A) when is_integer(A) ->
    A;
to_integer(A) when is_binary(A) ->
    binary_to_integer(A);
to_integer(A) when is_list(A) ->
    list_to_integer(A).
