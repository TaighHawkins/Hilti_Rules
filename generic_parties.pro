%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - GENERIC BUYER AND SUPPLIER PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( parties_rules, `26 September 2014` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Shortcut for calling Without Names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen1_uk_address( [ Member ] ), [ 
%=======================================================================

	gen1_address_details_without_names( Atoms )

	%	[ Left_Margin, Start, Street, AL, City, State, PC, End_Line ]
	
] )
:-
	( q_sys_is_string( Member )	->	Member_Usable = Member
		;	q_sys_is_atom( Member )	->	sys_string_atom( Member_Usable, Member )
	)
	
	, Endings = [ `_left_margin`, `_start_rule`, `_street`
				, `_address_line`, `_city`, `_state`, `_postcode`, `_end_line` ]
	
	, prepend_the_whole_list( Member_Usable, Endings, Strings )
	, transform_list( sys_string_atom, Strings, Atoms )
	, Atoms = [ Left_Margin, Start, Street, AL, City, State, PC, End_Line ]
	, !
.

prepend_the_whole_list( Beginning, [ ], [ ] ).
prepend_the_whole_list( Beginning, [ E_H | E_T ], [ S_H | S_T ] ):-

	  strcat_list( [ Beginning, E_H ], S_H )
	, prepend_the_whole_list( Beginning, E_T, S_T )
.

%=======================================================================
i_rule( gen1_uk_address( [ Member, postcode( PC, PC_Searcher ) ] ), [ 
%=======================================================================

	gen1_address_details_without_names( List )

	%	[ Left_Margin, Start, Street, AL, City, State, PC, End_Line ]
	
] )
:-
	( q_sys_is_string( Member )	->	Member_Usable = Member
		;	q_sys_is_atom( Member )	->	sys_string_atom( Member_Usable, Member )
	)
	
	, Endings = [ `_left_margin`, `_start_rule`, `_street`
				, `_address_line`, `_city`, `_state`, `_end_line` ]
	
	, prepend_the_whole_list( Member_Usable, Endings, Strings )
	, transform_list( sys_string_atom, Strings, Atoms )
	, Atoms = [ Left_Margin, Start, Street, AL, City, State, End_Line ]
	, List = [ Left_Margin, Start, Street, AL, City, State, postcode( PC, PC_Searcher ), End_Line ]
	, !
.

prepend_the_whole_list( Beginning, [ ], [ ] ).
prepend_the_whole_list( Beginning, [ E_H | E_T ], [ S_H | S_T ] ):-

	  strcat_list( [ Beginning, E_H ], S_H )
	, prepend_the_whole_list( Beginning, E_T, S_T )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Store Address predicate used by uers of the main rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_user_check( gen1_store_address_margin( LEFT_MARGIN_NAME ), START_POSITION, LEFT_TOLERANCE, RIGHT_TOLERANCE )
%-----------------------------------------------------------------------
:- 
%=======================================================================

	sys_assertz( i_user_data( address_margin( [ LEFT_MARGIN_NAME, START_POSITION, LEFT_TOLERANCE, RIGHT_TOLERANCE ] ) ) )

. %end%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The main rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( gen1_address_details_without_names( [ LEFT_MARGIN_NAME, START_LINE, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE_VAR ] ), [
%=======================================================================

	gen1_address_details_without_names( [ LEFT_MARGIN_NAME, START_LINE, STREET, ADDRESS_LINE, CITY, STATE, postcode( POSTCODE_VAR, POSTCODE_SEARCHER ) ] )

] )

:-

	POSTCODE_VAR \= postcode( _, _ ),

	POSTCODE_SEARCHER =.. [ POSTCODE_VAR, pc ]
.

%=======================================================================
i_rule_cut( gen1_address_details_without_names( [ LEFT_MARGIN_NAME, START_LINE, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE_VAR, END_LINE ] ), [
%=======================================================================

	gen1_address_details_without_names( [ LEFT_MARGIN_NAME, START_LINE, STREET, ADDRESS_LINE, CITY, STATE, postcode( POSTCODE_VAR, POSTCODE_SEARCHER ), END_LINE ] )

] )

:-
	POSTCODE_VAR \= postcode( _, _ ),

	POSTCODE_SEARCHER =.. [ POSTCODE_VAR, pc ]
.

%=======================================================================
i_rule_cut( gen1_address_details( [ LEFT_MARGIN_NAME, START_LINE, PARTY, CONTACT, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE_VAR ] ), [
%=======================================================================

	gen1_address_details( [ LEFT_MARGIN_NAME, START_LINE, PARTY, CONTACT, STREET, ADDRESS_LINE, CITY, STATE, postcode( POSTCODE_VAR, POSTCODE_SEARCHER ) ] )

] )

:-

	POSTCODE_VAR \= postcode( _, _ ),

	POSTCODE_SEARCHER =.. [ POSTCODE_VAR, pc ]
.

%=======================================================================
i_rule_cut( gen1_address_details( [ LEFT_MARGIN_NAME, START_LINE, PARTY, CONTACT, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE_VAR, END_LINE ] ), [
%=======================================================================

	gen1_address_details( [ LEFT_MARGIN_NAME, START_LINE, PARTY, CONTACT, STREET, ADDRESS_LINE, CITY, STATE, postcode( POSTCODE_VAR, POSTCODE_SEARCHER ), END_LINE ] )

] )

:-

	POSTCODE_VAR \= postcode( _, _ ),

	POSTCODE_SEARCHER =.. [ POSTCODE_VAR, pc ]
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( gen1_address_details_without_names( [ LEFT_MARGIN_NAME, START_LINE, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] ), [
%=======================================================================

	q0n(line),

	START_LINE, % which needs to set the left margin data

	% Note that without an end point we need to scan from the end backwards (which is expensive)

	or( [ [ qn0( gen1_address_part2( [ LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] ) ), with( POSTCODE_VAR ) ],

		qn0( gen1_address_part2( [ LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] ) )
	] )
] )

:-

	POSTCODE = postcode( POSTCODE_VAR, _ )
.

%=======================================================================
i_rule_cut( gen1_address_details_without_names( [ LEFT_MARGIN_NAME, START_LINE, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE, END_LINE ] ), [
%=======================================================================

%	why oh why was this here: peek_fails( END_LINE ), q0n( [ line, peek_fails( END_LINE ) ] ),

	q0n(line),

	START_LINE, % which needs to set the left margin data

	or( [ [ q0n( gen1_address_part2( [ END_LINE, LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] ) ), with( POSTCODE_VAR ) ],

		q0n( gen1_address_part2( [ END_LINE, LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] ) )
	] ),

	END_LINE
] )

:-

	POSTCODE = postcode( POSTCODE_VAR, _ )
.

%=======================================================================
i_rule_cut( gen1_address_details( [ LEFT_MARGIN_NAME, START_LINE, PARTY, CONTACT, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] ), [
%=======================================================================

	q0n(line),

	gen1_address_part1( [ LEFT_MARGIN_NAME, START_LINE, PARTY, CONTACT ] ),

	% Note that without an end point we need to scan from the end backwards (which is expensive)

	or( [ [ qn0( gen1_address_part2( [ LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] ) ), with( POSTCODE_VAR ) ],

		qn0( gen1_address_part2( [ LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] ) )
	] )
] )

:-

	POSTCODE = postcode( POSTCODE_VAR, _ )
.


%=======================================================================
i_rule_cut( gen1_address_details( [ LEFT_MARGIN_NAME, START_LINE, PARTY, CONTACT, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE, END_LINE ] ), [
%=======================================================================

%	why oh why was this here: peek_fails( END_LINE ), q0n( [ line, peek_fails( END_LINE ) ] ),

	q0n(line),

	gen1_address_part1( [ END_LINE, LEFT_MARGIN_NAME, START_LINE, PARTY, CONTACT ] ),

	or( [ [ q0n( gen1_address_part2( [ END_LINE, LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] ) ), with( POSTCODE_VAR ) ],

		q0n( gen1_address_part2( [ END_LINE, LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] ) )
	] ),

	END_LINE
] )

:-

	POSTCODE = postcode( POSTCODE_VAR, _ )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 1 - PARTY and CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen1_address_part1( [ LEFT_MARGIN_NAME, START_LINE, PARTY, CONTACT ] ), [
%=======================================================================

	START_LINE, % which needs to set the left margin data

	qn0( gen1_blank_line( [ LEFT_MARGIN_NAME ] ) ),

	or( [
		[ 
			gen1_contact_line( [ LEFT_MARGIN_NAME, CONTACT ] ),
			qn0( gen1_blank_line( [ LEFT_MARGIN_NAME ] ) ),
			q10( gen1_check_data_line( [ LEFT_MARGIN_NAME, PARTY, gen_company_clue ] ) )
		],

		[ 
			gen1_data_line( [ LEFT_MARGIN_NAME, CONTACT ] ),
			qn0( gen1_blank_line( [ LEFT_MARGIN_NAME ] ) ),
			gen1_check_data_line( [ LEFT_MARGIN_NAME, PARTY, gen_company_clue ] )
		],

		[ 
			gen1_check_data_line( [ LEFT_MARGIN_NAME, PARTY, gen_company_clue ] ),
			qn0( gen1_blank_line( [ LEFT_MARGIN_NAME ] ) ),
			q10( gen1_contact_line( [ LEFT_MARGIN_NAME, CONTACT ] ) )
		],

		gen1_data_line( [ LEFT_MARGIN_NAME, PARTY ] )
	] )
] ).

%=======================================================================
i_rule( gen1_address_part1( [ END_LINE, LEFT_MARGIN_NAME, START_LINE, PARTY, CONTACT ] ), [
%=======================================================================

	START_LINE, % which needs to set the left margin data

	qn0( [ peek_fails( END_LINE ), gen1_blank_line( [ LEFT_MARGIN_NAME ] ) ] ),

	peek_fails( END_LINE ),

	or( [
		[ 
			gen1_contact_line( [ LEFT_MARGIN_NAME, CONTACT ] ),
			qn0( [ peek_fails( END_LINE ), gen1_blank_line( [ LEFT_MARGIN_NAME ] ) ] ),
			q10( [ peek_fails( END_LINE ), gen1_check_data_line( [ LEFT_MARGIN_NAME, PARTY, gen_company_clue ] ) ] )
		],

		[ 
			gen1_data_line( [ LEFT_MARGIN_NAME, CONTACT ] ),
			qn0( [ peek_fails( END_LINE ), gen1_blank_line( [ LEFT_MARGIN_NAME ] ) ] ),
			peek_fails( END_LINE ),
			gen1_check_data_line( [ LEFT_MARGIN_NAME, PARTY, gen_company_clue ] )
		],

		[ 
			gen1_check_data_line( [ LEFT_MARGIN_NAME, PARTY, gen_company_clue ] ),
			qn0( [ peek_fails( END_LINE ), gen1_blank_line( [ LEFT_MARGIN_NAME ] ) ] ),
			q10( [ peek_fails( END_LINE ), gen1_contact_line( [ LEFT_MARGIN_NAME, CONTACT ] ) ] )
		],

		gen1_data_line( [ LEFT_MARGIN_NAME, PARTY ] )
	] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen1_contact_line( [ LEFT_MARGIN_NAME, CONTACT ] ), [
%=======================================================================

	or( [ 
		gen1_flagged_contact_line( [ LEFT_MARGIN_NAME, CONTACT ] ),

		gen1_check_data_line( [ LEFT_MARGIN_NAME, CONTACT, gen_contact_clue ] )
	] )
] ).

%=======================================================================
i_line_rule( gen1_flagged_contact_line( [ LEFT_MARGIN_NAME, CONTACT ] ), [
%=======================================================================

	nearest_word( LEFT_MARGIN_START, LEFT_TOLERANCE, RIGHT_TOLERANCE ),

	or( [
		[ `contact`, q10( `name ` ) ],

		[ or( [ `fao`, `attn`, [ `f`, `.`, `a`, `.`, `o` ] ] ), q10( `.` ) ],

		[ `for`, `the`, or( [ `attention`, [ `attn`, q10( `.` ) ] ] ), `of` ]
	] ),

	q10( tab(40) ), 

	q10( `:` ),

	q10( tab(40) ), 

	CONTACT_NAME_SEARCHER
] )

:-
	i_user_data( address_margin( [ LEFT_MARGIN_NAME, LEFT_MARGIN_START, LEFT_TOLERANCE, RIGHT_TOLERANCE ] ) ),

	CONTACT_NAME_SEARCHER =.. [ CONTACT, s ]

. %end%

%=======================================================================
i_rule( gen1_check_data_line( [ LEFT_MARGIN_NAME, DATUM, CHECK ] ), [
%=======================================================================

	gen1_data_line( [ LEFT_MARGIN_NAME, DATUM ] ),

	check( i_user_check( CHECK, DATUM ) )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 2 - ADDRESS and POSTCODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen1_address_part2( [ END_LINE, LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] ), [
%=======================================================================
	
	peek_fails( END_LINE ),

	gen1_address_part2( [ LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] )
] ).

%=======================================================================
i_rule_cut( gen1_address_part2( [ LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] ), [
%=======================================================================

	or( [
		gen1_blank_line( [ LEFT_MARGIN_NAME ] ),
		gen1_line_starts_with_postcode( [ LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] ),
		gen1_line_ends_with_postcode( [ LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] ),
		gen1_compound_data_line( [ LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, POSTCODE ] ),
		gen1_straight_address_line( [ LEFT_MARGIN_NAME, ADDRESS_LINE ] ) % if something that looks like a postcode appears in the *middle* of a line
	] )
] ).

%=======================================================================
i_line_rule( gen1_line_starts_with_postcode( [ LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, postcode( _, POSTCODE_SEARCHER ) ] ), [
%=======================================================================

	gen1_nearest_word( [ LEFT_MARGIN_NAME ] ),

	POSTCODE_SEARCHER,

	q10( `,` ),

	q10( tab(40) ), 

	gen1_compound_data( [ STREET, ADDRESS_LINE, CITY, STATE, POSTCODE_SEARCHER ] ),

	or( [ tab, newline ] )
] ).

%=======================================================================
i_line_rule( gen1_line_ends_with_postcode( [ LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, postcode( _, POSTCODE_SEARCHER ) ] ), [
%=======================================================================

	gen1_nearest_word( [ LEFT_MARGIN_NAME ] ),

	q01( or( [
			[	gen1_compound_data( [ STREET, ADDRESS_LINE, CITY, STATE, POSTCODE_SEARCHER ] ), or( [ `-`, `,` ] ) ],


			gen1_compound_data( [ STREET, ADDRESS_LINE, CITY, STATE, POSTCODE_SEARCHER ] )

	] ) ),

	or( [
		[ gen1_opt_comma_hyphen, tab(40), gen1_opt_comma_hyphen ],
			
		[ q10( tab(20) ), gen1_opt_comma_hyphen, q10( tab(20) ) ]

	] ),

	POSTCODE_SEARCHER,

	or( [ tab, newline ] )
] ).

%=======================================================================
i_rule( gen1_opt_comma_hyphen, [ q10( or( [ `-`, `,` ] ) ) ] ).
%=======================================================================

%=======================================================================
i_line_rule( gen1_compound_data_line( [ LEFT_MARGIN_NAME, STREET, ADDRESS_LINE, CITY, STATE, postcode( _, POSTCODE_SEARCHER ) ] ), [
%=======================================================================

	gen1_nearest_word( [ LEFT_MARGIN_NAME ] ),

	gen1_compound_data( [ STREET, ADDRESS_LINE, CITY, STATE, POSTCODE_SEARCHER ] ),

	or( [ tab, newline ] )
] ).

%=======================================================================
i_rule( gen1_compound_data( [ STREET, ADDRESS_LINE, CITY, STATE, POSTCODE_SEARCHER ] ), [
%=======================================================================

	qn0( gen1_compound_data_comma( [ STREET, ADDRESS_LINE, CITY, STATE, POSTCODE_SEARCHER ] ) ),

	q10( [	check( i_user_check( gen_unique_id, normal_sentence, ID, ID_S ) ),

		gen_non_postcode_sentence( [ ID, POSTCODE_SEARCHER ] ),

		gen1_allocate_address_sentence( [ ID_S, ID, STREET, ADDRESS_LINE, CITY, STATE ] )
	] )

] ).

%=======================================================================
i_rule( gen1_compound_data_comma( [ STREET, ADDRESS_LINE, CITY, STATE, POSTCODE_SEARCHER ] ), [
%=======================================================================

	check( i_user_check( gen_unique_id, comma_sentence, ID, ID_S ) ),

	gen_non_postcode_commad_sentence( [ ID, POSTCODE_SEARCHER ] ),

	gen1_allocate_address_sentence( [ ID_S, ID, STREET, ADDRESS_LINE, CITY, STATE ] )
] ).

%=======================================================================
i_rule( gen1_allocate_address_sentence( [ SENTENCE_NAME_STRING, SENTENCE, STREET, ADDRESS_LINE, CITY, STATE ] ), [
%=======================================================================

	% note, we cannot use (data) here because the sentence has been created through appends

	check( i_user_check( gen_string_trim, SENTENCE_NAME, SENTENCE_VALUE ) ),

	or( [ 
		gen1_bogus_hyphen_preceding_well_defined_item( [ SENTENCE_VALUE, ADDRESS_LINE, CITY, STATE, [] ] ),

		[
			check( i_user_check( gen_recognised_city, SENTENCE_VALUE ) ),

			ASSIGN_TO_CITY
		],

		[
			check( i_user_check( gen_recognised_county, SENTENCE_VALUE ) ),

			ASSIGN_TO_STATE
		],

		[
			check( i_user_check( gen_street_clue, SENTENCE_VALUE ) ),

			ASSIGN_TO_STREET
		],

		q10( [
			check( i_user_check( gen_string_length, SENTENCE_VALUE, AL_LEN ) ),

			check( AL_LEN > 1 ),

			ASSIGN_TO_ADDRESS_LINE
		] )
	] )
] )

:-

	sys_string_atom( SENTENCE_NAME_STRING, SENTENCE_NAME ),

	ASSIGN_TO_CITY =.. [ CITY, SENTENCE_VALUE ],

	ASSIGN_TO_STATE =.. [ STATE, SENTENCE_VALUE ],

	ASSIGN_TO_STREET =.. [ STREET, SENTENCE_VALUE ],

	ASSIGN_TO_ADDRESS_LINE =.. [ ADDRESS_LINE, SENTENCE_VALUE ]

. %end%

%=======================================================================
i_rule( gen1_bogus_hyphen_preceding_well_defined_item( [ SENTENCE_VALUE, ADDRESS_LINE, CITY, STATE, IGNORE_IX_LIST ] ), [
%=======================================================================

	or( [

		[	gen1_bogus_hyphen_preceding_well_defined_item_1( [ SPECIFIC_VALUE, CITY, STATE ] ),

			q10( [	check( HYP_IX > 1 ), 

				check( i_user_check( gen_sub_string, SENTENCE_VALUE, 1, LENGTH_OF_ADDRESS_LINE, ADDRESS_LINE_VALUE_1 ) ),

				check( i_user_check( gen_string_trim, ADDRESS_LINE_VALUE_1, ADDRESS_LINE_VALUE ) ),

				ASSIGN_TO_ADDRESS_LINE
			] )
		],

		gen1_bogus_hyphen_preceding_well_defined_item( [ SENTENCE_VALUE, ADDRESS_LINE, CITY, STATE, [ HYP_IX | IGNORE_IX_LIST ] ] )
	] )

] )

:-
	q_sys_sub_string( SENTENCE_VALUE, HYP_IX, 1, `-` ),

	not( q_sys_member( HYP_IX, IGNORE_IX_LIST ) ),

	sys_calculate( LENGTH_OF_ADDRESS_LINE, HYP_IX - 1 ),

	sys_calculate( START_OF_SPECIFIC, HYP_IX + 1 ),

	q_sys_sub_string(SENTENCE_VALUE, START_OF_SPECIFIC, _, SPECIFIC_VALUE_1 ),

	sys_string_trim( SPECIFIC_VALUE_1, SPECIFIC_VALUE ),

	ASSIGN_TO_ADDRESS_LINE =.. [ ADDRESS_LINE, ADDRESS_LINE_VALUE ]

. %end%

%=======================================================================
i_rule( gen1_bogus_hyphen_preceding_well_defined_item_1( [ SENTENCE_VALUE, CITY, STATE ] ), [
%=======================================================================

	or( [
		[
			check( i_user_check( gen_recognised_city, SENTENCE_VALUE ) ),

			ASSIGN_TO_CITY
		],

		[
			check( i_user_check( gen_recognised_county, SENTENCE_VALUE ) ),

			ASSIGN_TO_STATE
		]
	] )
] )

:-
	ASSIGN_TO_CITY =.. [ CITY, SENTENCE_VALUE ],

	ASSIGN_TO_STATE =.. [ STATE, SENTENCE_VALUE ]

. %end%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generic rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen1_nearest_word( [ LEFT_MARGIN_NAME ] ), [
%=======================================================================

	nearest_word( LEFT_MARGIN_START, LEFT_TOLERANCE, RIGHT_TOLERANCE )
	
] )

:-
	i_user_data( address_margin( [ LEFT_MARGIN_NAME, LEFT_MARGIN_START, LEFT_TOLERANCE, RIGHT_TOLERANCE ] ) )

. %end%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generic line rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_non_postcode_sentence( [ NAME, POSTCODE_SEARCHER ] ), [
%=======================================================================

	SET_NAME_TO_EMPTY, 

 	qn1( [ peek_fails( POSTCODE_SEARCHER ), append( SET_NAME_TO_W1, ``, ` ` ) ] )

] )

:-

	SET_NAME_TO_EMPTY =.. [ NAME, `` ],

	SET_NAME_TO_W1 =.. [ NAME, w1 ]

. %end%

%=======================================================================
i_rule( gen_non_postcode_commad_sentence( [ NAME, POSTCODE_SEARCHER ] ), [
%=======================================================================

	SET_NAME_TO_EMPTY,

	q0n( [ peek_fails( POSTCODE_SEARCHER ), append( SET_NAME_TO_W1, ``, ` ` ) ] ),

	append( SET_NAME_TO_COMMA_DELIMITED_WORD, ``, `` )
] )

:-

	SET_NAME_TO_EMPTY =.. [ NAME, `` ],

	SET_NAME_TO_W1 =.. [ NAME, w1 ],

	SET_NAME_TO_COMMA_DELIMITED_WORD =.. [ NAME, f( [ begin, q(any,0,999), end, q(other(","),1,1) ] ) ]

. %end%

%=======================================================================
i_line_rule( gen1_data_line( [ LEFT_MARGIN_NAME, DATUM ] ), [
%=======================================================================

	gen1_nearest_word( [ LEFT_MARGIN_NAME ] ),

	DATUM_SEARCHER
] )

:-
	DATUM_SEARCHER =.. [ DATUM, s ]

. %end%

%=======================================================================
i_line_rule( gen1_blank_line( [ LEFT_MARGIN_NAME ] ), [ peek_fails( gen1_nearest_word( [ LEFT_MARGIN_NAME ] ) ) ] ).
%=======================================================================

%=======================================================================
i_line_rule( gen1_straight_address_line( [ LEFT_MARGIN_NAME, ADDRESS_LINE ] ), [
%=======================================================================

	gen1_nearest_word( [ LEFT_MARGIN_NAME ] ),

	ADDRESS_LINE_SEARCHER
] )

:-
	ADDRESS_LINE_SEARCHER =.. [ ADDRESS_LINE, s1 ]

. %end%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fields which must now be carried through
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_user_field( invoice, buyer_left_margin, `left margin of the buyer address column` ).
%=======================================================================
i_user_field( invoice, supplier_left_margin, `left margin of the supplier address column` ).
%=======================================================================
