%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HILTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hilti_sales_response, `5 May 2014` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ set_test_flag, send_sales_update ]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( set_test_flag, [ set(test_flag) ]) :-  i_mail( to, `orders.test@adaptris.net` ).
%=======================================================================
i_rule( set_test_flag, [ set(test_flag) ]) :-  i_mail( to, `orders.test@ecx.adaptris.com` ).
%=======================================================================

%=======================================================================
i_rule( send_sales_update, [ 
%=======================================================================

	write([ `YTD Total`, `,`, `TP Ship-to`, `,`, `Speedy Ship-to`, `,`, `Territory`, `,`, `AM` ])
	, write_flush

     , check( i_user_check( get_list, LIST ) ) 

     , apply_list( [ LIST ] )

	, trace([ `Sales report created` ])

] ).


i_rule(write_to_line([LOCATION, VALUE]), [

	trace([ LOCATION, VALUE ])
	, check(i_user_check( gen_normalise_2dp_in_string, VALUE , VALUE_2dp ))
	, check(i_user_check( gen_string_to_upper, LOCATION, LU ))

     , or([ 
       [ test(test_flag), check(i_user_check( get_location_data_test, TP, SPEEDY, LU, AM )) ]		%TEST
         , check(i_user_check( get_location_data, TP, SPEEDY, LU, AM ))					%PROD
     ]) 

	, write([ VALUE_2dp,  `,`, TP, `,`, SPEEDY, `,`, LU, `,`, AM ])
	, write_flush

]).


%=======================================================================
i_rule( get_list( [ LIST ] ), [ check( i_user_check( get_list, LIST ) ) ] ).
%=======================================================================

%=======================================================================
i_user_check( get_list, LIST ) :- 	lookup_cache_list( `hilti_sales`, `territory`, `amount`, LIST ).
%=======================================================================

%=======================================================================
i_rule( apply_list( [ LIST ] ), RULES ) :-   convert_list_to_rules( LIST, RULES ).
%=======================================================================

%=======================================================================
convert_list_to_rules( [], [] ).
%=======================================================================
convert_list_to_rules( [ cache( A, B ) | T_IN ], [ write_to_line( [ A, B ] ) | T_OUT ] ) :- !, convert_list_to_rules( T_IN, T_OUT ).
%=======================================================================

%=======================================================================
i_user_check( get_location_data, TP, SPEEDY, LOCATION, AM )
:- sales_lookup(TP, SPEEDY, LOCATION, AM).
%=======================================================================
i_user_check( get_location_data_test, TP, SPEEDY, LOCATION, AM )
:- sales_lookup_test(TP, SPEEDY, LOCATION, AM).

%=======================================================================
% PROD

sales_lookup( `Travis Perkins Ship-to's`, `Speedy Ship-to's`, `Territory`, `Account Manager`).
sales_lookup( `20947598`, `21110080`, `TGB0100502`, `AM Rob Groat`).
sales_lookup( `21109905`, `20048769`, `TGB0200316`, `AM Andy Self`).
sales_lookup( `21109971`, `21110219`, `TGB0200314`, `AM Anthony Harvey`).
sales_lookup( `21109972`, `21110220`, `TGB0100801`, `AM Stuart Bailey`).
sales_lookup( `21109974`, `21110252`, `TGB0100512`, `AM Martin Scholey`).
sales_lookup( `21109975`, `21110253`, `TGB0200313`, `AM Christopher Windas`).
sales_lookup( `21109981`, `21110255`, `TGB0101105`, `AM Steven Young`).
sales_lookup( `21109982`, `21110291`, `TGB0200209`, `AM Chas Baker`).
sales_lookup( `21109984`, `21110293`, `TGB0100405`, `AM Chris Jordan`).
sales_lookup( `21109985`, `21110294`, `TGB0200501`, `AM Tom Clayton`).

%=======================================================================
% TEST

sales_lookup_test( `Travis Perkins Ship-to's`, `Speedy Ship-to's`, `Territory`, `Account Manager`).
sales_lookup_test( `11238605`, `11238595`, `TGB0100502`, `AM Michael Crawford`).
sales_lookup_test( `11238606`, `11232143`, `TGB0200316`, `AM Vince Edwards`).
sales_lookup_test( `11238607`, `11238596`, `TGB0200314`, `AM Anthony Harvey`).
sales_lookup_test( `11238608`, `11238597`, `TGB0100801`, `AM Stuart Bailey`).
sales_lookup_test( `11238609`, `11238598`, `TGB0100512`, `AM Martin Scholey`).
sales_lookup_test( `11238610`, `11238599`, `TGB0200313`, `AM Daljit Sangha`).
sales_lookup_test( `11238611`, `11238600`, `TGB0101105`, `AM Vacant 101105`).
sales_lookup_test( `11238612`, `11238601`, `TGB0200209`, `AM Ian Welch`).
sales_lookup_test( `11238613`, `11238602`, `TGB0200408`, `AM Jeremy Ratcliffe`).
sales_lookup_test( `11238614`, `11238603`, `TGB0100405`, `AM Chris Jordan`).
sales_lookup_test( `11238615`, `11238604`, `TGB0200501`, `AM Tom Clayton`).


