%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FR AXIMA MALAKOFF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fr_axima_malakoff, `18 May 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_op_param( custom_e1edk02_segments, _, _, _, `true` ):- grammar_set( quotation ).
i_user_field( invoice, quotation_number, `Quotation Number` ).
custom_e1edk02_segment( `004`, quotation_number ).

%=======================================================================
i_page_split_rule_list( [ check_for_number_of_quotations ] ).
%=======================================================================
i_rule_cut( check_for_number_of_quotations, [
%=======================================================================

	check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, qn0(
		or( [ 
			[ quotation_identifier_line
				, check( i_user_check( gen_cntr_inc_str, 20, Value ) )
			]
			
			, line
		] )
	)
	
	, check( i_user_check( gen_cntr_get, 20, Invoices ) )
	, continuation_page( Invoices )
	, trace( [ `Quotations on page: `, Invoices ] )
	
] ).

%=======================================================================
i_line_rule_cut( quotation_identifier_line, [ `Offre`, `de`, `prix`, `n`, `°` ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ check_if_quotation, get_fixed_variables, get_order_number ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( check_if_quotation, [
%=======================================================================
	
	q0n(line), quotation_identifier_line, set( quotation )
	
	, trace( [ `Processing as quotation` ] )
	
] ).

	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ get_quotation_number, get_delivery_date ] ):- grammar_set( quotation ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_order_date
	
	, get_delivery_date
	
	, get_delivery_details
	
	, get_buyer_contact
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_order_lines

	, get_totals
	
	, remove( delivery_date )

] ):- not( grammar_set( quotation ) ).

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
		, suppliers_code_for_buyer( `11721286` )		
	] )

	, type_of_supply( `01` )

	, set( reverse_punctuation_in_numbers )
	, set( leave_spaces_in_order_number )
	
	, sender_name( `Axima Nantes` )
	
] ):- not( grammar_set( quotation ) ).

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `FR-QUOTES` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0900`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10558391` ) ]	
		, suppliers_code_for_buyer( `11741986` )		
	] )
	
	, or( [ [ test( test_flag ), delivery_note_number( `10558391` ) ]	
		, delivery_note_number( `11741986` )		
	] )

	, sender_name( `Axima Malakoff` )
	, set( leave_spaces_in_order_number )
	
] ):- grammar_set( quotation ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUOTATION NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_quotation_number, [
%=======================================================================

	get_to_correct_quotation_number
	
	, generic_horizontal_details( [ [ `Offre`, `de`, `prix`, `n`, `°` ], quotation_number, s1 ] )
	
	, q10( [ with( order_number ), force_result( `success` ) ] )
	
] ).

%=======================================================================
i_rule_cut( find_a_quotation, [ q1n(line), peek_ahead( quotation_identifier_line ) ] ).
%=======================================================================
i_rule_cut( get_to_correct_quotation_number, [ 
%=======================================================================

	q( Count, Count, find_a_quotation )
	
] ):- i_mail( sub_document_count, Count ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q(0,30,line), generic_horizontal_details( [ [ `Commande`, `N`, `°` ], order_number, s1 ] )
	
	, q10( [ q(0,15,line)
		, generic_horizontal_details( [ [ `N`, `°`, `Affaire` ], order_number_y, sf, [ `:`, generic_item( [ order_number_z, s1 ] ) ] ] )
	
		, check( order_number = OrdX )
		, check( order_number_y = OrdY )
		, check( order_number_z = OrdZ )
		, check( strcat_list( [ OrdX, ` `, OrdY, OrdZ ], Order ) )
		, remove( order_number )
		, order_number( Order )
		, trace( [ `Full order number`, order_number ] )
	] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	q(0,30,line), generic_horizontal_details( [ [ `Du`, `:` ], invoice_date, date ] )
	
] ).

%=======================================================================
i_rule( get_delivery_date, [
%=======================================================================

	q(0,60,line), generic_vertical_details( [ [ `DATE`, `DE`, `LIVRAISON` ], `Livraison`, delivery_date, date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	q(0,60,line), generic_horizontal_details( [ [ `Adresse`, `de`, `livraison` ] ] )
	
	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 20 ] ) )
	
	, generic_horizontal_details_cut( [ nearest( generic_hook(start), 10, 20 ), delivery_party, s1 ] )
	
	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 20 ] ) )
	
	, generic_horizontal_details_cut( [ nearest( delivery_party(start), 10, 20 ), delivery_street, s1 ] )
	
	, delivery_postcode_and_city_line
	
	, q10( [ qn0( gen_line_nothing_here( [ generic_hook(start), 10, 20 ] ) )
		, delivery_contact_line 
	] )
	
] ).

%=======================================================================
i_line_rule_cut( delivery_postcode_and_city_line, [
%=======================================================================

	nearest( delivery_party(start), 10, 20 )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ], q10( tab ) ] )
	
	, generic_item( [ delivery_city, w ] )
	
] ).

%=======================================================================
i_line_rule( delivery_contact_line, [
%=======================================================================

	nearest( delivery_party(start), 10, 10 )
	
	, `Réception`, `quantitative`, `par`, `:`, word, `.`
	
	, generic_item( [ delivery_contact, w ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	q(0,30,line), generic_horizontal_details( [ [ `Rédacteur`, `:` ], buyer_contact, s1 ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	qn0(line), generic_horizontal_details( [ [ at_start, `Total` ], total_net, d, [ `€`, newline ] ] )
	
	, check( total_net = Net )
	, total_invoice( Net )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_order_lines, first_one_only ).
%=======================================================================
i_section( get_order_lines, [
%=======================================================================

	  line_header_line
	 
	, q0n(
		or( [ line_order_rule
			, line
		] )
	)
	
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Réf`, `.`, tab, `DESIGNATION`, q0n(anything), read_ahead( `Qté` ), qty_hook(w) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Total`, tab ] ).
%=======================================================================
i_rule_cut( line_order_rule, [
%=======================================================================

	line_order_line
	
	, q10( [ with( invoice, delivery_date, Date )
		, line_original_order_date( Date )
	] )
	
	, count_rule

] ).

%=======================================================================
i_rule_cut( back_to_the_beginning, [ qn0( back ) ] ).
%=======================================================================
i_line_rule_cut( line_order_line, [
%=======================================================================

	  nearest( qty_hook(start), 10, 30 ), generic_item( [ num, d ] )
	  
	, back_to_the_beginning
	
	, generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ], q10( tab ) ] )
	
	, q10( `-` ), generic_item( [ line_descr, s1, tab ] )
	
	, generic_item_cut( [ cond, d, tab ] )
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, tab ] )
	
	, generic_item_cut( [ line_unit_amount, d, [ q10( `€` ), tab ] ] )
	
	, generic_item_cut( [ line_net_amount, d, [ q10( `€` ), newline ] ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

i_op_param( orders05_idocs_first_and_last_name( delivery_contact, ``, Name ), _, _, _, _ )
:-
	not( grammar_set( quotation ) ),
	result( _, invoice, delivery_contact, Name )
.