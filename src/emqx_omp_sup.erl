%%--------------------------------------------------------------------
%% Copyright (c) 2025 EMQ Technologies Co., Ltd. All Rights Reserved.
%%--------------------------------------------------------------------

-module(emqx_omp_sup).

-include("emqx_omp.hrl").

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    ChildSpecs = [
    ],
    SupFlags = #{
        strategy => one_for_all,
        intensity => 10,
        period => 10
    },
    {ok, {SupFlags, ChildSpecs}}.
