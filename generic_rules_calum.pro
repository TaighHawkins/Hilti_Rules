%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - GENERIC RULES CALUM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( generic_rules_calum, `2 July 2015` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%		CONTENTS:
%
% 	- generic_line
% 	- generic_descr_append
% 	- generic_process_rule
% 	- gen_supplier
% 	- gen_capture
% 	- gen_vert_capture
% 	- gen_section
% 	- gen_section_2
%	- gen_beof
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GENERIC LINE
%%%
%%%		23-07-2014
%%%		-	Initial Implementation
%%%			-	Simply allows for a line rule to be called within a line
%%%			-	Should not be used to avoid typing out line rules of
%%%				higher complexity
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( generic_line( [ Line ] ), [ Line ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GENERIC DESCR APPEND
%%%
%%%		23-09-2014
%%%		-	Initial Implementation
%%%			-	For appending a sentence to a line description
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( generic_descr_append, [
%=======================================================================

	with(line_descr), append( line_descr(s1), ` `, `` ), newline, trace( [ `descr appended` ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GENERIC PROCESS RULE
%%%
%%%		01-09-2014
%%%		-	Initial Implementation
%%%			-	For identifying 'junk', statements and documents that require forwarding.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( generic_process_rule( [ Rule, N, Action ] ), [
%=======================================================================

	check( not( q_sys_var(Action) ) )
	
	, q(0,N,line), Rule

	, or( [

		[ check( Action = `forward` )

			, set( forward_document ), trace( [ `forward_document` ] )

		]

		, [ check( Action = `junk` )

			, set( chain, `junk` ), trace( [ `junk` ] )

		]

		, [ check( Action = `statement` )

			, set( statement ), trace( [ `statement` ] )

		]

		, [ check( Action = `correspond` )

			, set( correspond ), trace( [ `correspond` ] )

		]

	] )

	, set( do_not_process ), trace( [ `Setting 'do_not_process' flag` ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN SUPPLIER
%%%
%%%		29-10-2014
%%%		-	Initial Implementation
%%%			-	For setting the supplier details from the i_rule_list
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_supplier( [ Name, Postcode, VAT_Number ] ), [
%=======================================================================
	
	supplier_party(Name)
	
	, sender_name(Name)
	
	, supplier_postcode(Postcode)
	
	, supplier_vat_number(VAT_Number)

] ).

%=======================================================================
i_rule( gen_supplier( [ Name, Postcode ] ), [
%=======================================================================
	
	supplier_party(Name)
	
	, sender_name(Name)
	
	, supplier_postcode(Postcode)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN CAPTURE
%%%
%%%		29-10-2014
%%%		-	Initial Implementation
%%%			-	For capturing a variable from the i_rule_list using generic_horizontal_details
%%%			
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_capture( [ Search, Length_of_tab, Variable, Type, After ] ), [
%=======================================================================
	
	q0n(line), generic_horizontal_details( [ Search, Length_of_tab, Variable, Type, After ] )
	
] ).

%=======================================================================
i_rule( gen_capture( [ Search, Param_2, Param_3, Param_4 ] ), [
%=======================================================================
	
	q0n(line), generic_horizontal_details( [ Search, Param_2, Param_3, Param_4 ] )
	
] ).

%=======================================================================
i_rule( gen_capture( [ Param_1, Param_2, Param_3 ] ), [
%=======================================================================
	
	q0n(line), generic_horizontal_details( [ Param_1, Param_2, Param_3 ] )
	
] ).

%=======================================================================
i_rule( gen_capture( [ Variable, Type ] ), [
%=======================================================================
	
	q0n(line), generic_horizontal_details( [ Variable, Type ] )
	
] ).

%=======================================================================
i_rule( gen_capture( [ Param_1 ] ), [
%=======================================================================
	
	q0n(line), generic_horizontal_details( [ Param_1 ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN VERT CAPTURE
%%%
%%%		06-11-2014
%%%		-	Initial Implementation
%%%			-	For capturing a variable from the i_rule_list using generic_vertical_details
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_vert_capture( [ Search, Hook, Position, Left, Right, Variable, Type, After ] ), [
%=======================================================================

	q0n(line), generic_vertical_details( [ Search, Hook, Position, Left, Right, Variable, Type, After ] )
	
] ).

%=======================================================================
i_rule( gen_vert_capture( [ Param_1, Param_2, Param_3, Param_4, Param_5, Param_6, Param_7 ] ), [
%=======================================================================

	q0n(line), generic_vertical_details( [ Param_1, Param_2, Param_3, Param_4, Param_5, Param_6, Param_7 ] )
	
] ).

%=======================================================================
i_rule( gen_vert_capture( [ Param_1, Param_2, Param_3, Param_4, Param_5, Param_6 ] ), [
%=======================================================================

	q0n(line), generic_vertical_details( [ Param_1, Param_2, Param_3, Param_4, Param_5, Param_6 ] )
	
] ).

%=======================================================================
i_rule( gen_vert_capture( [ Param_1, Param_2, Param_3, Param_4, Param_5 ] ), [
%=======================================================================

	q0n(line), generic_vertical_details( [ Param_1, Param_2, Param_3, Param_4, Param_5 ] )
	
] ).

%=======================================================================
i_rule( gen_vert_capture( [ Param_1, Param_2, Param_3, Param_4 ] ), [
%=======================================================================

	q0n(line), generic_vertical_details( [ Param_1, Param_2, Param_3, Param_4 ] )
	
] ).

%=======================================================================
i_rule( gen_vert_capture( [ Param_1, Param_2, Param_3 ] ), [
%=======================================================================

	q0n(line), generic_vertical_details( [ Param_1, Param_2, Param_3 ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN SECTION
%%%
%%%		29-10-2014
%%%		-	Initial Implementation
%%%			-	For defining a generic section from the i_rule_list
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( gen_section( [ Rule_1, Rule_2, Rule_3 ] ), [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)
	
		, or( [ Rule_1, Rule_2, Rule_3, line ] )
		
	] )

] ).

%=======================================================================
i_section( gen_section( [ Rule_1, Rule_2 ] ), [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)
	
		, or( [ Rule_1, Rule_2, line ] )
		
	] )

] ).

%=======================================================================
i_section( gen_section( [ Rule_1 ] ), [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)
	
		, or( [ Rule_1, line ] )
		
	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN SECTION 2
%%%
%%%		29-10-2014
%%%		-	Initial Implementation
%%%			-	For defining a second generic section from the i_rule_list
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( gen_section_2( [ Rule_1, Rule_2, Rule_3 ] ), [
%=======================================================================

	line_header_line_2

	, qn0( [ peek_fails(line_end_line_2)
	
		, or( [ Rule_1, Rule_2, Rule_3, line ] )
		
	] )

] ).

%=======================================================================
i_section( gen_section_2( [ Rule_1, Rule_2 ] ), [
%=======================================================================

	line_header_line_2

	, qn0( [ peek_fails(line_end_line_2)
	
		, or( [ Rule_1, Rule_2, line ] )
		
	] )

] ).

%=======================================================================
i_section( gen_section_2( [ Rule_1 ] ), [
%=======================================================================

	line_header_line_2

	, qn0( [ peek_fails(line_end_line_2)
	
		, or( [ Rule_1, line ] )
		
	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN BEOF
%%%
%%%		11-12-2014
%%%		-	or( [ at_start, tab ] )
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_beof, [ or( [ at_start, tab ] ) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GENERIC NO
%%%
%%%		05-02-2015
%%%		-	Captures a number into a variable and traces it out
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( generic_no( [ Variable, Param, After ] ), [
%=======================================================================

	Read_Variable, After, trace( [ Variable_Name, Variable ] )

] )
:-
	q_sys_is_atom( Variable ),
	not( q_sys_var( Param ) ),
	q_sys_member( Param, [ d, n, d1 ] ),
	
	Read_Variable =.. [ Variable, Param ],

	sys_string_atom( Variable_Name, Variable ),
	
	!
.

%=======================================================================
i_rule( generic_no( [ Variable, Param ] ), [
%=======================================================================

	Read_Variable, trace( [ Variable_Name, Variable ] )

] )
:-
	q_sys_is_atom( Variable ),
	not( q_sys_var( Param ) ),
	q_sys_member( Param, [ d, n ] ),
	
	Read_Variable =.. [ Variable, Param ],
	
	sys_string_atom( Variable_Name, Variable ),
	
	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		CHECK FOR REVERSE PUNCTUATION
%%%
%%%		06-03-2015
%%%		-	For capturing numbers that may or may not reverse punctuation
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_reverse_punctuation( [ Variable, Param, After ] ), [
%=======================================================================

	q10( [ read_ahead( numeric(f([ begin, q(other("-"),0,1), q([dec,other(".")],0,10), q(other(","),1,1), q(dec,2,2), q(other("-"),0,1), end ])) )
	
		, set( reverse_punctuation_in_numbers )
		
		, trace( [ `Reversed punctuation` ] )
		
	] )
	
	, check( not( q_sys_var( Param ) ) )
	, check( q_sys_member( Param, [ d, n ] ) )
	
	, generic_no( [ Variable, Param, After ] )
	
	, clear( reverse_punctuation_in_numbers )

] ).

%=======================================================================
i_rule( check_for_reverse_punctuation( [ Variable, Param ] ), [ check_for_reverse_punctuation( [ Variable, Param, none ] ) ] ).
%=======================================================================