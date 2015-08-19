%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - GENERIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( generic_rules, `03 March 2015` ).

i_rules_file( `generic_rules_calum.pro` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handle the minus sign preceding the pound sign
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_read_amount_with_negative_before_pound_sign( [ ITEM ] ), [
%=======================================================================

	or( [
		[ `-`, `£`, NEGATIVE_ITEM ]

		, [ `£`, POSITIVE_ITEM ]
	] )

]

:-

	POSITIVE_ITEM =.. [ ITEM, d ]

	, NEGATIVE_ITEM =.. [ ITEM, n ]

. %end%

%=======================================================================
i_rule( gen_negativised_read_amount_with_negative_before_pound_sign( [ ITEM ] ), [
%=======================================================================

	or( [
		[ `-`, `£`, POSITIVE_ITEM ]

		, [ `£`, NEGATIVE_ITEM ]
	] )

]

:-

	POSITIVE_ITEM =.. [ ITEM, d ]

	, NEGATIVE_ITEM =.. [ ITEM, n ]

. %end%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Count the number of lines until a match
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( gen_count_lines( [ RULE, 0 ] ), [ RULE ] ).
%=======================================================================
i_rule_cut( gen_count_lines( [ RULE, N ] ), [ line, gen_count_lines( [ RULE, M ] ), check( i_user_check( gen_add, M, 1, N ) ) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEMPLATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_separator, [ or( [ `-`, `/`, `\\` ] ) ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remember to peek_ahead this !!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( gen_trace_line, [ dummy(s1), trace( [ gen_trace_line, dummy ] ) ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_date, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	invoice_date( f( [ begin , q(dec,1,2) , end ] ) ) 

	, gen_separator

	, append(
			invoice_date( f( [ begin , q(dec,1,2) , end ] ) ) 

			, `/`, ``
	)
		
	, gen_separator

	, append(
			invoice_date( f( [ begin , q(dec,2,4) , end ] ) ) 

			, `/`, ``
	)
] )

. %end%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_prefix(50), [] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_prefix(TAB), [ q0n(anything), tab(TAB) ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_start_of_phrase, [ q01( [ q0n(anything), tab ] ) ] ). % note this does not MOVE to the start of a phrase!!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_postfix(TAB), [ tab(TAB) ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_postfix(50), [ newline ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_eof, [ or( [ tab, newline ] ) ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( gen_line_nothing_here( [ START, BEFORE, AFTER ] ), [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	peek_fails( nearest( START, BEFORE, AFTER ) )
] )

. %end%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( gen_line_nothing_here( [ START, END, BEFORE, AFTER ] ), [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	peek_fails( nearest( START, END, BEFORE, AFTER ) )
] )

. %end%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I_USER_CHECK routines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_checkmark, NAME ) :- i_marked_region( NAME ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_recognised_city, CITY ) :- lookup_city( CITY ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_recognised_county, COUNTY ) :- lookup_county( COUNTY ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_street_clue, STREET ) :- lookup_street_clue( STREET ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_company_clue, COMPANY ) :- lookup_company_clue( COMPANY ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_secondary_company_clue, COMPANY ) :- lookup_secondary_company_clue( COMPANY ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_contact_clue, CONTACT ) :- lookup_contact_clue( CONTACT ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_presence, A ) :- q_sys_is_string( A ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_instantiated, A ) :- not( q_sys_var( A ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_number_to_string, A, B ) :- sys_string_number( B, A ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_str_add, A, B, A_plus_B ) :- sys_calculate_str_add( A, B, A_plus_B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_str_subtract, A, B, A_minus_B ) :- sys_calculate_str_subtract( A, B, A_minus_B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_str_multiply, A, B, A_mult_B ) :- sys_calculate_str_multiply( A, B, A_mult_B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_str_divide, A, B, A_div_B ) :- sys_calculate_str_divide( A, B, A_div_B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_normalise_2dp_in_string, A, A_2dp ) :- normalise_2dp_in_string( A, A_2dp ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_q_sys_comp_str_eq, A, B ) :- q_sys_comp_str_eq( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_q_sys_comp_str_gt, A, B ) :-  q_sys_comp_str_gt( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_q_sys_comp_str_lt, A, B ) :-  q_sys_comp_str_lt( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_q_sys_comp_str_ge, A, B ) :-  q_sys_comp_str_ge( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_q_sys_comp_str_le, A, B ) :-  q_sys_comp_str_le( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_q_sys_comp_str_approx_equal, A, B, Tolerance ) :-  q_sys_comp_str_approx_equal( A, B, Tolerance ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_add, A, B, A_plus_B ) :- sys_calculate( A_plus_B, A + B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_subtract, A, B, A_minus_B ) :- sys_calculate( A_minus_B, A - B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_divide, A, B, A_div_B ) :- sys_calculate( A_div_B, A // B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_mod, A, B, A_mod_B ) :- sys_calculate( A_mod_B, A mod B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_2dp_mult, A, B, A_times_B ) :- sys_calculate( A_times_B, ( ( A * 100 * B ) // 1 ) / 100 ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_2dp_divide, A, B, A_div_B ) :- sys_calculate( A_div_B, ( ( A * 100 ) // B ) / 100 ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_average, A, B, Avg ) :- sys_calculate( Avg, ( A + B ) // 2 ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_same, A, B ) :- A = B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_different, A, B ) :- A \= B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_lt, A, B ) :- A < B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_le, A, B ) :- A =< B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_gt, A, B ) :- A > B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_ge, A, B ) :- A >= B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_member, A, B ) :- q_sys_member( A,  B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_not_member, A, B ) :- not( q_sys_member( A,  B ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_string_length, A, B ) :- sys_string_length( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_string_trim, A, B ) :- sys_string_trim( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_string_number, A, B ) :- sys_string_number( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_string_to_lower, A, B ) :- string_to_lower( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_string_to_upper, A, B ) :- string_to_upper( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_string_replace, A, B, C, D ) :- string_string_replace( A, B, C, D ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_sub_string, A, B, C, D ) :- q_sys_sub_string( A, B, C, D ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_op_param, A, B ) :- qq_op_param( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_cntr_set, CNTR, VALUE ) :- sys_cntr_set( CNTR, VALUE ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_cntr_get, CNTR, VALUE ) :- sys_cntr_get( CNTR, VALUE ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_cntr_get_str, CNTR, VALUES ) :- sys_cntr_get( CNTR, VALUE ), sys_string_number( VALUES, VALUE).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_cntr_inc, CNTR, VALUE ) :- sys_cntr_inc( CNTR, VALUE ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_cntr_inc_str, CNTR, VALUES ) :- sys_cntr_inc( CNTR, VALUE ), sys_string_number( VALUES, VALUE).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_cntr_dec, CNTR, VALUE ) :- sys_cntr_dec( CNTR, VALUE ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_cntr_dec_str, CNTR, VALUES ) :- sys_cntr_dec( CNTR, VALUE ), sys_string_number( VALUES, VALUE).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_unique_id, PREFIX, ID, ID_S )
%-----------------------------------------------------------------------
:-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	sys_string_atom( PREFIX_S, PREFIX ),

	sys_cntr_inc( 9, UID ),

	sys_string_number( UID_S, UID ),

	sys_strcat( PREFIX_S, UID_S, ID_S ),

	sys_string_atom( ID_S, ID )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( approx_equal_percent, A, B, P )
%-----------------------------------------------------------------------
:-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	sys_calculate( Tolerance, A * P / 100 )

	, i_user_check( approx_equal, A, B, Tolerance )

. %end%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( approx_equal, A, B )
%-----------------------------------------------------------------------
:-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	i_user_check( approx_equal, A, B, 5 )

. %end%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( approx_equal, A, B, Tolerance )
%-----------------------------------------------------------------------
:- 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	sys_calculate( Diff, abs( A - B ) )
	
	, q_sys_comp( Diff < Tolerance )

. %end%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some generic formats for regexp parsing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_data( gen_somewhere_format( WHAT, [ p(any,0,999) , strong, q(WHAT,1,1) ] ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% best_address_match predicate should be of the form: Postcode, Address_String, Code
%
% call with check( i_user_check( best_address_match, Table_predicate_name, Postcode_found, Address_string_found, Returned_code ) )
%
%	-	Updated the Address modifier to use a match 'score' instead of direct comparison
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
best_address_match_ignore_words( [ `street`, `road` ] ).
%===============================================================================

%===============================================================================
i_user_check( best_address_match, BCFB, Pc, Address, Match )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	string_to_lower( Pc, Pc_lower )
	, string_to_lower( Address, Address_lower )
	, q_sys_is_string( BCFB )
	, string_to_lower( BCFB, BCFBL )
	
	, strcat_list( [ `arco_`, BCFBL, `_address_lookup` ], Table )
	, trace( [ `TableName`, Table ] )
	, q_gratabase_check_table_exists( Table, Exists )
	
	, sys_findall( ( A, C ), ( q_gratabase_lookup( Table, [ _, Pc_lower, _, _ ], [ _, _, A1, C ], Available ), sys_string_tokens( A1, A ) ), Matches )
	, ( Matches = [ ( _, Match ) ] -> true ; best_address_match_fit( Address_lower, Matches, Match ) )
.


%===============================================================================
i_user_check( best_address_match, Predicate, Pc, Address, Match )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	string_to_lower( Pc, Pc_lower )

	, string_to_lower( Address, Address_lower )

	, Matcher =.. [ Predicate, Pc_lower, A1, C ]

	, sys_findall( ( A, C ), ( Matcher, sys_string_tokens( A1, A ) ), Matches )
	
	, ( Matches = [ ( _, Match ) ] -> true ; best_address_match_fit( Address_lower, Matches, Match ) )
.

%===============================================================================
i_user_check( best_address_match, Predicate, Dept, Pc, Address, Match )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	string_to_lower( Pc, Pc_lower )

	, string_to_lower( Address, Address_lower )
	
	, string_to_lower( Dept, Dept_lower )

	, Matcher =.. [ Predicate, Dept_lower, Pc_lower, A1, C ]

	, sys_findall( ( A, C ), ( Matcher, sys_string_tokens( A1, A ) ), Matches )
	
	, ( Matches = [ ( _, Match ) ] -> true ; best_address_match_fit( Address_lower, Matches, Match ) )
.

%===============================================================================
i_user_check( best_address_match_numeric_pc, Predicate, Pc, Address, Match )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	  string_to_lower( Address, Address_lower )

	, Matcher =.. [ Predicate, Pc, A1, C ]

	, sys_findall( ( A, C ), ( Matcher, sys_string_tokens( A1, A ) ), Matches )
	
	, ( Matches = [ ( _, Match ) ] -> true ; best_address_match_fit( Address_lower, Matches, Match ) )
.

%===============================================================================
best_address_match_fit( Address, Matches, Match )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	sys_string_tokens( Address, AT1 )
	
	, best_address_match_ignore_words( IW )
	
	, compare_lists( AT1, IW, AT )
	
	, sys_asserta( best_address_match_fit_pattern( AT ) )
	
	, transform_list( best_address_match_fit_analysis, Matches, Analysed_matches )   
	
	, sys_retract( best_address_match_fit_pattern( AT ) )
	
	, sys_sort( Analysed_matches, [ ( _, Match ) | _ ] )
.

%===============================================================================
best_address_match_fit_analysis( ( In, In_code ), ( Match_Score, In_code ) )
%-------------------------------------------------------------------------------
:-
%===============================================================================
	
	best_address_match_fit_pattern( AT )
	
	, best_address_match_ignore_words( IW )	%	Unreasonable to remove them from lookup
	, compare_lists( In, IW, In_x )			%	and not the address on the doc
	
	, compare_lists( AT, In_x, Left )
	, compare_lists( In_x, AT, Remainder )
	
	, length( Left, Result )
	, length( Remainder, Rem_Result )	%	Need to know what is left
	
	, sys_calculate( Test, 1 * 10 )
	
	, sys_calculate( Result_Coefficient, 10 * Result )	%	Worse to miss a token
	, sys_calculate( Match_Score, Result_Coefficient + Rem_Result )	%	Than to have excess in the string
	
	, trace( match( Match_Score ) )	%	Perfect match will score zero
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ARCO LINE ITEM SEARCH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( arco_item_search_rule, [ 
%=======================================================================

	  line_item( f( Format ) )
	  
	, trace( [ `line item`, line_item ] )
	
] ):-  i_user_data( arco_item_format( Format ) ).

%=======================================================================
i_rule( arco_item_x_search_rule, [ 
%=======================================================================

	  line_item_x( f( Format ) )
	  
	, trace( [ `line item x`, line_item_x ] )
	
] ):-  i_user_data( arco_item_format( Format ) ).

%=======================================================================
i_user_data( arco_item_format( [ begin, q(alpha("BMDC"),0,2), q(dec,1,1), q([dec,alpha],4,8), end ] ) ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HORIZONTAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%	-	10/07/2014
%%%		-	Updated to use generic_item as the variable capture
%%%		-	Reducing redundancy
%%%		-	Updated so that specifying a tab length doesn't demand the 'After' parameter
%%%
%%%	-	28/08/2014
%%%		-	Updated Searching ability
%%%			-	If the use of 'at_start' at the beginning of the search then q0n(anything) will not be called
%%%
%%%	-	03/09/2014
%%%		-	Tidied the post :- Prologue
%%%			-	Removed redundancy in or statement
%%%
%%%	-	25/09/2014
%%%		-	Changed three variable version to identify through parameter instead of after
%%%
%%%	-	27/11/2014
%%%		-	Updated to allow full regular expressions to be called and identified
%%%
%%%	-	05/02/2015
%%%		-	Added a cut after the anchor endings
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Single Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( generic_horizontal_details_cut( [ Search ] ), [ generic_horizontal_details( [ Search ] ) ] ).
%=======================================================================
i_line_rule( generic_horizontal_details( [ Search ] ), [
%=======================================================================

	or( [ [ check( Skip = `skip` ), q0n(anything) ]
	  
		, [ check( Skip = `noskip` ) ]
		
	] )
	
	, read_ahead( Search )
	
	, q10( tab ), generic_hook(w)
	
	, trace( [ `Start position stored in generic_hook(start)` ] )	

] )
:-
	get_skip_indicator( Search, Skip )	
	, !	
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Two Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( generic_horizontal_details_cut( [ Variable, Parameter ] ), [ generic_horizontal_details( [ Variable, Parameter ] ) ] ).
%=======================================================================
i_line_rule( generic_horizontal_details( [ Variable, Parameter ] ), [ horizontal_details( [ `no_search`, 1, Variable, Parameter, none ] ) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Three Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( generic_horizontal_details_cut( [ Variable, Parameter, After ] ), [ generic_horizontal_details( [ Variable, Parameter, After ] ) ] ).
%=======================================================================
i_line_rule( generic_horizontal_details( [ Variable, Parameter, After ] ), [ horizontal_details( [ `no_search`, 1, Variable, Parameter, After ] ) ] )
%-----------------------------------------------------
:-
%=======================================================================
	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )
	
		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )		
	
		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	)
.

%=======================================================================
i_rule_cut( generic_horizontal_details_cut( [ Search, Variable, Parameter ] ), [ generic_horizontal_details( [ Search, Variable, Parameter ] ) ] ).
%=======================================================================
i_line_rule( generic_horizontal_details( [ Search, Variable, Parameter ] ), [ horizontal_details( [ Search, 100, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------
:-
%=======================================================================
	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )
	
		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )		
	
		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Four & Five Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( generic_horizontal_details_cut( [ Search, Tab_Length, Variable, Parameter ] ), [ generic_horizontal_details( [ Search, Tab_Length, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------
:-	q_sys_is_number( Tab_Length ).
%=======================================================================

%=======================================================================
i_line_rule( generic_horizontal_details( [ Search, Tab_Length, Variable, Parameter ] ), [ horizontal_details( [ Search, Tab_Length, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------
:- q_sys_is_number( Tab_Length ).
%=======================================================================

%=======================================================================
i_rule_cut( generic_horizontal_details_cut( [ Search, Variable, Parameter, After ] ), [ generic_horizontal_details( [ Search, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_line_rule( generic_horizontal_details( [ Search, Variable, Parameter, After ] ), [ horizontal_details( [ Search, 100, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_rule_cut( generic_horizontal_details_cut( [ Search, Tab_Length, Variable, Parameter, After ] ), [ generic_horizontal_details( [ Search, Tab_Length, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_line_rule( generic_horizontal_details( [ Search, Tab_Length, Variable, Parameter, After ] ), [ horizontal_details( [ Search, Tab_Length, Variable, Parameter, After ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( horizontal_details( [ Search, Tab_Length, Variable, Parameter, After ] ), [
%=======================================================================

	  or( [ [ check( Skip = `skip` ), q0n(anything) ]
	  
		, [ check( Skip = `noskip` ) ]
		
	] )
	
	, xor( [ check( Search_Ind = `none` )

			, [ check( Search_Ind = `normal` ), Search ]
		
	] )
  
	, skip_anchor_endings
	
	, xor( [ [ check( Tab_Length >	100 ), tab( Tab_Length ) ]
	
		, [ check( Tab_Length < 101 ), q10( tab( Tab_Length ) ) ]
		
	] )

	, generic_item( [ Variable, Parameter, After ] )

] )
:-
	
	get_search_indicator( Search, Search_Ind )
	, get_skip_indicator( Search, Skip )	
	, !	
.

%=======================================================================
i_rule_cut( skip_anchor_endings, [ q(3,0, or( [ `:`, `-`, `;`, `.` ] ) ) ] ).
%=======================================================================


get_search_indicator( Search, Search_Ind )
:-	
	q_sys_is_string( Search )
	, Search = `no_search`
	->	Search_Ind = `none` 

	;	Search_Ind = `normal`
.

get_skip_indicator( Search, Skip )
:-
	( q_sys_is_list( Search )			
		, Search = [ H | _ ]
		
		;	Search = H
	)

%	To improve efficiency in searches that want to start at the beginning of the line			
	, H = at_start
	->	Skip = `noskip`

	; 	Skip = `skip`
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERIC ITEM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%	-	Bug found! 	Fixed( 04/06/2014 )
%%%		-	If the 'after' parameter was left empty then the none used as 
%%%			an atom to signify the end ( and is left in to keep compatibility )
%%%			then it could be called upon to capture a word
%%%
%%%	-	28/08/2014 OPTIONAL is legacy
%%%		-	Introduced a better method to convert the old optional method into the new method
%%%		-	Tidier OR statement at the end
%%%
%%%	-	03/09/2014
%%%		-	Tidied the post :- Prologue
%%%			-	Removed redundancy in or statement
%%%
%%%	-	27/11/2014
%%%		-	Allowed use of full regular expressions within the rule (fd( _ ) and f( _ ))
%%%
%%%	-	05/02/2015
%%%		-	Introduced cuts to prevent backtracking - previously the rule will retry 2-3 times after a failure
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( generic_item_cut( [ Variable, Parameter, Optional, Spacing ] ), [ generic_item( [ Variable, Parameter, Optional, Spacing ] ) ] ).
%=======================================================================
i_rule( generic_item( [ Variable, Parameter, Optional, Old_Spacing ] ), [ 
%=======================================================================

	generic_item( [ Variable, Parameter, Spacing ] )
	
] )
:-
	( Optional = `not`
		->	trace( `Remove 'not' from rules - obsolete and incompatible` )
			, Spacing = Old_Spacing
			
		;	not( Optional = `not` )
			, sys_string_atom( Optional, Atom )
			, Spacing =.. [ Atom, Old_Spacing ]	
			
	), !

.

%=======================================================================
i_rule( generic_item( [ Variable, Parameter ] ), [ generic_item_rule( [ Variable, Parameter, none ] ) ] ).
%=======================================================================
i_rule( generic_item( [ Variable, Parameter, Spacing ] ), [ generic_item_rule( [ Variable, Parameter, Spacing ] ) ] ).
%=======================================================================

%=======================================================================
i_rule_cut( generic_item_cut( [ Variable, Parameter ] ), [ generic_item_rule( [ Variable, Parameter, none ] ) ] ).
%=======================================================================
i_rule_cut( generic_item_cut( [ Variable, Parameter, Spacing ] ), [ generic_item_rule( [ Variable, Parameter, Spacing ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( generic_item_rule( [ Variable, Parameter, Spacing ] ), [ 
%=======================================================================

	xor( [ [ check( Numerical = `true` ), skip_currency ]
		
		, check( Numerical = `false` )
	] )

	, Read_Variable

	, or( [ [ check( Numerical = `true` ), q10( `%` ) ]
	
		, check( Numerical = `false` )
	] )

	, xor( [ [ check( Spacing_String = `VOID` )
			, Spacing
			
		]
		
		, [ check( not( Spacing_String = `none` ) )	
			, check( not( Spacing_String = `VOID` ) )	
			, Spacing
			
		]

		, check( Spacing_String = `none` )

	] )
	
	, trace( [ Variable_Name, Variable ] )

] )
:-

	( q_sys_is_list( Parameter ) 
		->	Full_Param =.. [ f, Parameter ],
			Read_Variable =.. [ Variable, Full_Param ]
	
		;	Read_Variable =.. [ Variable, Parameter ]
		
	),
	
	( ( 	Param =.. [ fd | _ ]
			;	q_sys_member( Param, [ d, n ] )
		)
		->	Numerical = `true`
		
		;	Numerical = `false`
	),

	sys_string_atom( Variable_Name, Variable ),
	
	( q_sys_is_atom( Spacing ), sys_string_atom( Spacing_String, Spacing )
	
		;	Spacing_String = `VOID`
		
	), !
.

%=======================================================================
i_rule_cut( skip_currency, [ q10( or( [ `$`, `£`, `€` ] ) ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VERTICAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%	-	10/07/2014
%%%		-	Updated to use generic_item as the variable capture
%%%		-	Reducing redundancy
%%%		-	Updated variations that can be called:
%%%	
%%%			-	Three parameter which will search for the first string
%%%				in the search to use as the anchor
%%%			-	Several new versions which don't require the 'After'
%%%				parameter
%%%			
%%%	-	14/07/2014	
%%%		-	Could be called 'incorrectly'	
%%%		-	Updated to check and added another variety
%%%
%%%	-	25/09/2014
%%%		-	Updated the anchor-less versions to deal with or statements as the search
%%%		-	Will not cope with first item in a list being an or statement however
%%%
%%%	-	27/11/2014
%%%		-	Updated to allow full regular expressions to be called and identified
%%%
%%%	-	03/03/2015
%%%		-	Two changes
%%%			-	Introduction of ability to specify number of lines to be captured
%%%			-	Change in the way the parameters are specified for the nearest function to use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Three Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Variable, Parameter ] )] ).
%=======================================================================
i_rule( generic_vertical_details( [ Search, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, start, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------
:-
%=======================================================================
	
	( q_sys_is_list( Search )	->	Search_List = Search
	
		;	Search_List = [ Search ]
		
	)

	, search_for_string( Search_List, Anchor ), !
.

search_for_string( Search, Anchor ):-

	Search = [ Potential_Anchor | Tail ],
		
	( not( Potential_Anchor =.. [ or | _ ] )	
		->	( q_sys_is_string( Potential_Anchor ) -> Anchor = Potential_Anchor
	
				; search_for_string( Tail, Anchor )
			
			)
			
		;	Potential_Anchor =.. [ or | [ Or_Lists ] ],
			search_or_list_for_anchors( Or_Lists, Anchor )
	)
.

search_or_list_for_anchors( Lists_In, Or_Out )
:-
	search_lists_for_anchors( Lists_In, Anchor_List ),
	Or_Out =.. [ or | [ Anchor_List ] ]
.

search_lists_for_anchors( [ List_H | List_T ], [ Anchor_H | Anchor_T ] )
:-
	( q_sys_is_list( List_H )	-> List_H_List = List_H
	
		;	List_H_List = [ List_H ]
	),
	
	search_for_string( List_H_List, Anchor_H ),
	
	( List_T = [ ] 
		-> true
		
		;	search_lists_for_anchors( List_T, Anchor_T )
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Four Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_rule( generic_vertical_details( [ Search, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Anchor, start, 10, 10, Variable, Parameter, After ] ) ] )
%-----------------------------------------------------
:-
%=======================================================================
	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )
	
		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )		
	
		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	),
	
	( q_sys_is_list( Search )	->	Search_List = Search
	
		;	Search_List = [ Search ]
		
	),

	search_for_string( Search_List, Anchor ), !
.

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Anchor, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, start, 10, 10, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------
:-
%=======================================================================
	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )
	
		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )		
	
		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	)
.

%=======================================================================
i_rule( generic_vertical_details( [ Search, Anchor, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, start, 10, 10, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------
:-
%=======================================================================
	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )
	
		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )		
	
		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Five Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Anchor, Pos, Variable, Parameter ] ), [ eneric_vertical_details( [ Search, Anchor, Pos, 10, 10, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------
:-	q_sys_member( Pos, [ start, end ] ).
%=======================================================================

%=======================================================================
i_rule( generic_vertical_details( [ Search, Anchor, Pos, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, Pos, 10, 10, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------
:-	q_sys_member( Pos, [ start, end ] ).
%=======================================================================

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Anchor, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Anchor, start, 10, 10, Variable, Parameter, After ] ) ] )
%-----------------------------------------------------
:-
%=======================================================================
	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )
	
		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )		
	
		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	)
.

%=======================================================================
i_rule( generic_vertical_details( [ Search, Anchor, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Anchor, start, 10, 10, Variable, Parameter, After ] ) ] )
%-----------------------------------------------------
:-
%=======================================================================
	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )
	
		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )		
	
		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Six Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Anchor, Pos, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Anchor, Pos, 10, 10, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_rule( generic_vertical_details( [ Search, Anchor, Pos, Variable, Parameter, After ] ), [
%=======================================================================

	  generic_vertical_details( [ Search, Anchor, Pos, 10, 10, Variable, Parameter, After ] )

] ):- q_sys_member( Pos, [ start, end ] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Seven Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Anchor, Pos, Left, Right, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------
:-	q_sys_is_number( Left ), q_sys_is_number( Right ).
%=======================================================================

%=======================================================================
i_rule( generic_vertical_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------
:-	q_sys_is_number( Left ), q_sys_is_number( Right ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Eight Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Anchor, Pos, Left, Right, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_rule( generic_vertical_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter, After ] ), [
%=======================================================================

	  look_for_anchor( [ Search, Anchor ] ) 
	  
	, q01( line ), look_for_detail( [ Pos, Left, Right, Variable, Parameter, After ] )

] ).


i_rule( generic_vertical_details( [ Search, Anchor, LineMul, PosVar, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, LineMul, PosVar, Variable, Parameter, none ] ) ] ).

i_rule( generic_vertical_details( [ Search, Anchor, LineMul, PosVar, Variable, Parameter, After ] ), [

	look_for_anchor( [ Search, Anchor ] )
	
	, Lines, look_for_detail( [ Pos, Left, Right, Variable, Parameter, After ] )
	
] ):-
	( q_sys_member( LineMul, [ q01, q10, qn1, q1n ] )
		->	Lines =.. [ LineMul, line ]
		
		;	LineMul = q(LineMin,LineMax)
			->	Lines = q(LineMin,LineMax,line)
		
		;	( not( i_user_data( multiplier_traced_for( Variable ) ) )
				->	trace( [ `Line Multiplier invalid, defaulting to q01` ] ),
					sys_assertz( i_user_data( multiplier_traced_for( Variable ) ) )
					
				;	i_user_data( multiplier_traced_for( Variable ) )
			),
			Lines = q01(line)
	),!,
	
	( q_sys_member( PosVar, [ start, end ] )
		->	( not( i_user_data( anchor_traced_for( Variable ) ) )
				->	trace( [ `Only anchor point defined, defaulting tolerance` ] ),
					sys_assertz( i_user_data( anchor_traced_for( Variable ) ) )
					
				;	i_user_data( anchor_traced_for( Variable ) )
			),
			PosVar = Pos,
			Left = 10,
			Right = 10
			
		;	PosVar = ( PosX, LeftX, RightX ),
			( q_sys_member( PosX, [ start, end ] )
				->	Pos = PosX
				
				;	( not( i_user_data( anchor_traced_for( Variable ) ) )
						->	trace( [ `Anchor Point in incorrect format, defaulting to start` ] ),
							sys_assertz( i_user_data( anchor_traced_for( Variable ) ) )
					
						;	i_user_data( anchor_traced_for( Variable ) )
					),
					Pos = start
			),
			
			tolerance_check( Variable, left, LeftX, Left ),
			tolerance_check( Variable, right, RightX, Right )
	), !
.
			
tolerance_check( Variable, Side, TolIn, TolOut )
:-
	( q_sys_is_number(TolIn)
		->	TolIn = TolOut
		
		;	q_sys_is_string(TolIn),
			q_regexp_match( `^\\d+$`, TolIn, _ )
			->	sys_string_number( TolIn, TolOut )
		
		;	( not( i_user_data( tolerance_check( Variable, Side, TolIn ) ) )
				->	trace( [ `Tolerance invalid: `, TolIn, ` defaulting to 10` ] ),
					sys_assertz( i_user_data( tolerance_check( Variable, Side, TolIn ) ) )
					
				;	i_user_data( tolerance_check( Variable, Side, TolIn ) )
			),
			TolOut = 10
	),!
.

%=======================================================================
i_line_rule( look_for_anchor( [ Search, Anchor ] ), [
%=======================================================================

	  q0n(anything)
	  
	, read_ahead( Search )
	
	, q0n(anything), read_ahead( Anchor )
	
	, anchor(w)
	
	, trace( [ `found anchor` ] )

] ).

%=======================================================================
i_line_rule( look_for_detail( [ Pos, Left, Right, Variable, Parameter, After ] ), [
%=======================================================================

	  nearest( anchor(Pos), Left, Right )
		
	, generic_item( [ Variable, Parameter, After ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		Gen1_parse_text_rule
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		--		Reads a paragraph of text attempting to extract data from it
%%%
%%%		-	Left and Right are the start and end points for the paragraph
%%%		-	End Line is the line after the end of the paragraph
%%%		-	Search is in case there is an anchor within the text that should be used
%%%		-	Expression is in the form [ begin, q..., end ] and will form a regular expression for identification of the desired data
%%%			-	Exception!! If there is a search or keyword before the desired data then the regular parameters can be used.
%%%
%%%		-	Bug Found	( Fixed April )
%%%			-	If the capture of the item was failed, a backtrack into the 'gen_count_lines' would be attempted
%%%			-	This resulted in it counting over a useful line - this has been wrapped in a cut to prevent the backtracking
%%%
%%%		-	Bug Found		( Fixed 04/06/2014 )
%%%			-	captured_text was unavailable if the 'Search' parameter was populated
%%%
%%%		-	10/07/2014
%%%			-	Introduced 3 variable version - just to utilise the captured_text variable
%%%
%%%		-	Bug Found		( Fixed 12/12/2014 )
%%%			-	Search Parameter removed the cut on the count so the count could be re-done if no values were found.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen1_parse_text_rule( [ Left, Right, End_Line ] ), [ gen1_parse_text_rule( [ Left, Right, End_Line, dummy, [ begin, q(any,1,20),end ] ] ) ] ).
%=======================================================================
i_rule( gen1_parse_text_rule( [ Left, Right, End_Line, Variable_List, Expression_List ] ), [
%=======================================================================

	  peek_ahead( count_lines_for_parse( [ End_Line, Count_less_1 ] ) )

	, check( sys_calculate( Count, Count_less_1 + 1 ) )
	
	, read_ahead( [ 
	
		xor( [ [ check( q_sys_is_list( Variable_List ) ), trace( [ `Multi Read` ] )
	
				, parse_text_line( Count, Left, Right, [ Variable_List, Expression_List ] )
				
			]
			
			, [ trace( [ `Single Read` ] )
			
				, parse_text_line_single( Count, Left, Right, [ Variable_List, Expression_List ] )
				
			]
			
		] )
		
	] )

	, capture_parse_line( Count, Left, Right )
	
] ).

%=======================================================================
i_rule_cut( count_lines_for_parse( [ End_Line, Count_less_1 ] ), [ line, gen_count_lines( [ End_Line, Count_less_1 ] ) ] ).
%=======================================================================
i_line_rule( capture_parse_line, [ captured_text(s1), qn0( [ tab, append( captured_text(s1), ` `, `` ) ] ) ] ).
%=======================================================================
i_line_rule( parse_text_line_single( [ Variable, Expression ] ), [ parse_text_rule_single( [ Variable, Expression ] ) ] ).
%=======================================================================
i_line_rule( parse_text_line( [ Variable_List, Expression_List ] ), [ parse_text_rule( [ Variable_List, Expression_List ] ) ] ).
%=======================================================================
i_rule( parse_text_rule_single( [ Variable, Expression ] ), [
%=======================================================================

	  q0n(anything)
	  
	, Read_Variable
	
	, trace( [ String, Variable ] )

] ):-

	  Full_Exp =.. [ f, Expression ]	  
	, Read_Variable =.. [ Variable, Full_Exp ]	
	, sys_string_atom( String, Variable )
.

%=======================================================================
i_rule( parse_text_rule( [ [ V_H | V_T ], [ E_H | E_T ] ] ), [
%=======================================================================

	  q0n(anything)
	  
	, Read_Variable
	
	, trace( [ String, V_H ] )
	
	, parse_text_rule( [ V_T, E_T ] )

] ):-

	  Full_Exp =.. [ f, E_H ]	  
	, Read_Variable =.. [ V_H, Full_Exp ]	
	, sys_string_atom( String, V_H )
.

%=======================================================================
i_rule( parse_text_rule( [ [ ], [ ] ] ), [ ] ).
%=======================================================================

%=======================================================================
i_rule( gen1_parse_text_rule( [ Left, Right, End_Line, Search_List, Variable_List, Expression_List ] ), [
%=======================================================================

	  peek_ahead( count_lines_for_parse( [ End_Line, Count_less_1 ] ) )
	
	, check( sys_calculate( Count, Count_less_1 + 1 ) )
	
	, read_ahead( [ 

		xor( [ [ check( q_sys_is_list( Variable_List ) ), trace( [ `Multi Read` ] )
		
				, parse_text_line( Count, Left, Right, [ Search_List, Variable_List, Expression_List ] )
				
			]
			
			, [ trace( [ `Single Read` ] )
			
				, parse_text_line_single( Count, Left, Right, [ Search_List, Variable_List, Expression_List ] )
				
			]
			
		] )
		
	] )
	
	, capture_parse_line( Count, Left, Right )
	
] ).

%=======================================================================
i_line_rule( parse_text_line_single( [ Search, Variable, Expression ] ), [ parse_text_rule_single( [ Search, Variable, Expression ] ) ] ).
%=======================================================================
i_line_rule( parse_text_line( [ Search_List, Variable_List, Expression_List ] ), [
%=======================================================================

	  parse_text_rule( [ Search_List, Variable_List, Expression_List ] )

] ).

%=======================================================================
i_rule( parse_text_rule_single( [ Search, Variable, Expression ] ), [
%=======================================================================

	  q0n(anything)
  
	, Search
	  
	, Read_Variable
	
	, trace( [ String, Variable ] )

] ):-
	( q_sys_is_list( Expression )
	  
		->	  Full_Exp =.. [ f, Expression ]	  
				, Read_Variable =.. [ Variable, Full_Exp ]	
				
		;	  q_sys_is_atom( Expression )
			, Read_Variable =.. [ Variable, Expression ]
		
	)
	, sys_string_atom( String, Variable )
.

%=======================================================================
i_rule( parse_text_rule( [ [ S_H | S_T ], [ V_H | V_T ], [ E_H | E_T ] ] ), [
%=======================================================================

	  q0n(anything)

	, S_H
	
	, Read_Variable
	
	, trace( [ String, V_H ] )
	
	, parse_text_rule( [ S_T, V_T, E_T ] )

] ):-
	( q_sys_is_list( E_H )
	  
		->	  Full_Exp =.. [ f, E_H ]	  
				, Read_Variable =.. [ V_H, Full_Exp ]	
				
		;	  q_sys_is_atom( E_H )
			, Read_Variable =.. [ V_H, E_H ]
		
	)	
	, sys_string_atom( String, V_H )
.

%=======================================================================
i_rule( parse_text_rule( [ [ ], [ ], [ ] ] ), [ ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		Generic Invoice Line
%%%
%%%		11/07/2014
%%%		-	Initial Implementation
%%%			To only be used on well spaced things
%%%			-	generic_item_cut used to prevent numbers backtracking into
%%%				decimals to encourage capture of other variables
%%%
%%%		-	Added append function
%%%
%%%		05/02/2014
%%%		-	Tidied logic - made q10 and q01 take more affect
%%%
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( gen1_invoice_line( [ List_of_Vars ] ), [ 
%=======================================================================

	  gen1_invoice_line_rule( [ List_of_Vars ] )
	
] ).

%=======================================================================
i_rule( gen1_invoice_line_rule( [ [ ] ] ), [ newline, trace( [ `Finished Line` ] ) ] ).
%=======================================================================
i_rule( gen1_invoice_line_rule( [ List_of_Vars ] ), [ 
%=======================================================================

	  intelligent_line_item_read( [ H ] )
	
	, gen1_invoice_line_rule( [ T ] )
	
] ):-

	List_of_Vars = [ H | T ]
.

%=======================================================================
i_rule( intelligent_line_item_read( [ H ] ), [ 
%=======================================================================

	  generic_item_cut( [ H, Parameter, q10( tab ) ] )
	
] ):-
	  
	  q_sys_is_atom( H )
	, sys_string_atom( String, H )
	
	, check_for_parameter( String, Parameter )
	
.

check_for_parameter( Variable, Parameter ):-

	  (	q_sys_sub_string( Variable, _, _, `date` )	->	Parameter = date
	
		;	q_sys_sub_string( Variable, _, _, `uom` )	->	Parameter = s1
	
		;	q_sys_member( Number, [ `amount`, `total`, `rate`, `vat`, `net`, `line_quantity` ] )
			, q_sys_sub_string( Variable, _, _, Number )
			->	Parameter = d
			
		;	Parameter = s
	
	), !
.

%=======================================================================
i_rule( intelligent_line_item_read( [ H ] ), [ H ] ):- q_sys_is_string( H ).
%=======================================================================

%=======================================================================
i_rule( intelligent_line_item_read( [ H ] ), [ 
%=======================================================================

	append( Append_Var, ` `, `` ), q10( tab )
	
	, trace( [ `Appended: `, String ] )
	
] ):-
	
	H = ( append, Variable )

	, q_sys_is_atom( Variable )
	, sys_string_atom( String, Variable )
	
	, check_for_parameter( String, Parameter )
	, Append_Var =.. [ Variable, Parameter ]
.

%=======================================================================
i_rule( intelligent_line_item_read( [ H ] ), [ 
%=======================================================================

	Capture

] ):-
	
	H = ( Q, Variable )
	, q_sys_member( Q, [ q10, q01 ] )

	, q_sys_is_atom( Variable )
	, sys_string_atom( String, Variable )
	
	, check_for_parameter( String, Parameter )
	
	, Capture =.. [ Q, generic_item( [ Variable, Parameter, q10( tab ) ] ) ]
.

%=======================================================================
i_rule( intelligent_line_item_read( [ H ] ), [ 
%=======================================================================

	generic_item_cut( [ Variable, Parameter, q10( tab ) ] )
	
] ):- H = ( Variable, Parameter ).

%=======================================================================
i_rule( intelligent_line_item_read( [ H ] ), [ 
%=======================================================================

	Capture
	
] ):-
	H = ( Q, Variable, Parameter )
	, q_sys_member( Q, [ q10, q01 ] )
	, Capture =.. [ Q, generic_item_cut( [ Variable, Parameter, q10( tab ) ] ) ]
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		Gramatica Month Lookup
%%%
%%%		23-10-2014
%%%		-	Allows control of all the dates and formats
%%%			-	Will look into turning it into a table
%%%			-	Keep track of ALL changes here!
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


i_short_month(1,M) :- ( i_date_language( french ) -> M = `janv` ; M = `jan` ).
i_short_month(2,M) :- ( i_date_language( french ) -> M = `févr` ; M = `feb` ).
i_short_month(3,M) :- ( i_date_language( dutch ) -> M = `mrt` ; i_date_language( french ) -> M = `mars` ; M = `mar` ).
i_short_month(4,M) :- ( i_date_language( french ) -> M = `avril` ; M = `apr` ).
i_short_month(5,M) :- ( i_date_language( dutch ) -> M = `mei` ; i_date_language( french ) -> M = `mai` ; M = `may` ).
i_short_month(6,M) :- ( i_date_language( french ) -> M = `juin` ; M = `jun` ).
i_short_month(7,M) :- ( i_date_language( french ) -> M = `juil` ; M = `jul` ).
i_short_month(8,M) :- ( i_date_language( french ) -> M = `août` ; M = `aug` ).
i_short_month(9,`sept`).
i_short_month(9,`sep`).
i_short_month(10,M) :- ( i_date_language( dutch ) -> M = `okt` ; M = `oct` ).
i_short_month(11,`nov`).
i_short_month(12,M) :- ( i_date_language( french ) -> M = `déc` ; M = `dec` ).

i_long_month(1,M) :- ( i_date_language( dutch ) -> M = `januari` ; i_date_language( french ) -> M = `janvier` ; M = `january` ).
i_long_month(2,M) :- ( i_date_language( dutch ) -> M = `februari` ; i_date_language( french ) -> M = `février` ; M = `february` ).
i_long_month(3,M) :- ( i_date_language( dutch ) -> M = `maart` ; i_date_language( french ) -> M = `mars` ; M = `march` ).
i_long_month(4,M) :- ( i_date_language( french ) -> M = `avril` ; M = `april` ).
i_long_month(5,M) :- ( i_date_language( dutch ) -> M = `mei` ; i_date_language( french ) -> M = `mai` ; M = `may` ).
i_long_month(6,M) :- ( i_date_language( dutch ) -> M = `juni` ; i_date_language( french ) -> M = `juin` ; M = `june` ).
i_long_month(7,M) :- ( i_date_language( dutch ) -> M = `juli` ; i_date_language( french ) -> M = `juillet` ; M = `july` ).
i_long_month(8,M) :- ( i_date_language( dutch ) -> M = `augustus` ; i_date_language( french ) -> M = `août` ; M = `august` ).
i_long_month(9,M) :- ( i_date_language( french ) -> M = `septembre` ; M = `september` ).
i_long_month(10,M) :- ( i_date_language( dutch ) -> M = `oktober` ; i_date_language( french ) -> M = `octobre` ; M = `october` ).
i_long_month(11,M) :- ( i_date_language( french ) -> M = `novembre` ; M = `november` ).
i_long_month(12,M) :- ( i_date_language( french ) -> M = `décembre` ; M = `december` ).





	