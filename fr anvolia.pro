%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FR ANVOLIA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fr_anvolia, `20 February 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_op_param( custom_e1edk02_segments, _, _, _, `true` ).
i_user_field( invoice, quotation_number, `Quotation Number` ).
custom_e1edk02_segment( `004`, quotation_number ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	check_if_quotation
	
	, get_fixed_variables
	
	, get_order_number
	
	, get_delivery_date
	
	, get_quotation_number 
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `FR-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0900`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10558391` ) ]	
		, suppliers_code_for_buyer( `11661510` )		
	] )
	
	, or( [ [ test( test_flag ), delivery_note_number( `10558391` ) ]	
		, delivery_note_number( `11661510` )		
	] )

	, type_of_supply( `01` )
	
	, sender_name( `S.A.S. Anvolia` )
	, set( leave_spaces_in_order_number )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUOTATION NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_quotation_number, [
%=======================================================================

	q0n(line), line_header_line
	
	, q(0,10,line), quotation_number_line(2)
	
	, q10( [ with( order_number ), force_result( `success` ) ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Ref`, `AC` ] ).
%=======================================================================
i_line_rule_cut( quotation_number_line, [ 
%=======================================================================

	q0n(anything), or( [ `Offre`, `Devis` ] ), q10( [ `N`, `°` ] )
	
	, generic_item( [ quotation_number, [ begin, q(dec("9"),1,1), q(dec,8,8), end ] ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q(0,30,line), generic_horizontal_details( [ [ `Bon`, `de`, `commande` ] ] )
	
	, qn0( gen_line_nothing_here( [ generic_hook(start), 0, 100 ] ) )
	
	, generic_horizontal_details( [ nearest( generic_hook(start), 0, 100 ), order_number, s1 ] )
	, remove( generic_hook )
	
	, q(0,20,line), generic_horizontal_details( [ `AFFAIRE` ] )
	
	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
	
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 40 ), order_number_y, s1 ] )

	, check( order_number_y = Y )
	, append( order_number( Y ), ` `, `` )
	
] ).

%=======================================================================
i_rule( get_delivery_date, [
%=======================================================================

	q(0,60,line), generic_horizontal_details( [ [ `Date`, `De`, `Livraison` ] ] )
	
	, q(0,5,line), generic_horizontal_details( [ nearest( generic_hook(start), 10, 60 ), delivery_date, date ] )
	
] ).