%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HILTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hilti_rules, `9 Apr 2014` ).

%i_pdf_parameter( tab, 16 ).
%i_pdf_parameter( direct_object_mapping, 0 ).
% i_pdf_parameter( max_pages, 10).

i_rule_list( [ set(chain,`unrecognised`), select_buyer] ).

%=======================================================================
i_rule( select_buyer, [ or( [ test_delay_rule, [ q0n(line), check_text_identification_line, set_delay_rule ], [ q0n(line), buyer_id_line, set_delay_rule ] ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( test_delay_rule, [
%=======================================================================

	check( i_user_check( test_delay ))

	, set( chain, `*delay*` )

	, trace( [ `Delay found`] )

]).

%=======================================================================
i_rule( set_delay_rule, [
%=======================================================================

	check( i_user_check( set_delay ))

	, trace( [ `Delay set`] )

]).



%=======================================================================
i_user_check( test_delay )
%-----------------------------------------------------------------------
:-
%=======================================================================

	lookup_cache(  `hilti`, `sales`, `0`, `delay`, `1` )


. %end%

%=======================================================================
i_user_check( set_delay )
%-----------------------------------------------------------------------
:-
%=======================================================================

	set_cache(  `hilti`, `sales`, `0`, `delay`, `1` )

	, time_get( now, time( _, M, _ ) )

	, sys_string_number( MS, M )

	, set_cache(  `hilti`, `delay`, `0`, `time`, MS )

	, save_cache

. %end%


%=======================================================================
i_line_rule( buyer_id_line, [
%=======================================================================

	q0n(anything)

	, or( [

		 [ `(`, `01604`, `)`, `752424`, set(chain, `travis perkins (hilti)`), trace([`TRAVIS PERKINS (HILTI)`]) ]

		 , [ `(`, `01604`, `)`, `752424`, set(chain, `travis perkins (hilti)`), trace([`TRAVIS PERKINS (HILTI)`]) ]


	] )
	
] ).

%=======================================================================
i_line_rule( check_text_identification_line, [
%=======================================================================

	  or([

		  [ check_text( i_speedy_check ), set(chain, `GB-SPEEDY`), trace([`SPEEDY ...`]) ]
	
		, [ check_text( `travisperkinstradingco+` ),set(chain, `travis perkins (tradacom)`), trace([`TP TRADACOM ...`]) ]
	

	])
	
] ).

i_speedy_check( TEXT ) :- string_to_lower(TEXT, TL), q_sys_sub_string( TL, _, _, `speedy`), q_sys_sub_string( TL, _, _, `limited`). 


