%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT COMAU
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_comau, `24 July 2015` ).

% i_pdf_parameter( same_line, 8 ).

i_date_format( _ ).
i_format_postcode( X, X ).
i_op_param( xml_transform( delivery_street, In ), _, _, _, Out )
:-
	string_string_replace( In, `,`, ` `, Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, gen_vert_capture( [ [ `N`, `°`, `ORDINE`, `/`, `P`, `.`, `O`, `.`, `NUMBER` ], `ORDINE`, end, order_number, s1 ] )
	, gen_vert_capture( [ [ `DATA`, `1a`, `ED`, `.`, `/`, `1st`, `ISSUE`, `DATE` ], `ED`, q(0,2), end, invoice_date, date ] )
	
	, get_delivery_address
	
	, get_contact
	
	, get_shipping_instructions
	
	, check_vers_and_rev

	, get_invoice_totals

	, get_invoice_lines
	
] ).

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

	, buyer_registration_number( `IT-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Comau S.p.a.` )
	
	, delivery_party( `COMAU SPA` )

	, suppliers_code_for_buyer( `13144749` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	  q(0,35,line)
	
	, generic_horizontal_details( [ [ `Consegnare`, `a`, `:` ] ] )
	
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_dept, s1 ] )
	
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_street, s1 ] )
	
	, delivery_city_state_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_city_state_postcode_line, [ 
%=======================================================================

	  nearest( generic_hook(start), 10, 20 )
	
	, `I`, `-`, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )

	, generic_item( [ delivery_city, sf ] )

	, generic_item( [ delivery_state, [ q(other("("),0,1), begin, q(alpha,2,2), end, q(other(")"),0,1) ], gen_eof ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contact, [
%=======================================================================

	  q(0,35,line)
	
	, generic_vertical_details( [ [ `CONTRATTATORE`, `/`, `BUYER`, `CODE` ], contact, s1, [ tab, `Tel` ] ] )
	
	, check( i_user_check( reverse_names_in_contact, contact, Contact ) )
	
	, buyer_contact( Contact )
	, delivery_contact( Contact )
	, trace( [ `contact`, Contact ] )
	
] ).

%-----------------------------------------------------------------------
i_user_check( reverse_names_in_contact, Contact_in, Contact )
%-----------------------------------------------------------------------
:-
	sys_string_split( Contact_in, ` `, [ Last, First ] ),
	strcat_list( [ First, ` `, Last ], Contact )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [
%=======================================================================

	  q0n(line)
	
	, generic_line( [ [ `CONDIZIONI`, `DI`, `RESA` ] ] )
	
	, q(0,4, or( [ shipping_instructions_line(1,-500,-250), line ] ) )
	
	, generic_line( [ [ `RIGA`, tab, `RIF`, `.`, `INTERNI` ] ] )
	
	, trace( [ `got shipping instructions` ] )
	
] ).

%=======================================================================
i_line_rule( shipping_instructions_line, [
%=======================================================================

	  or( [
	
		[ test( ship ), append( shipping_instructions(s1), ` `, `` ) ]
		
		, generic_item( [ shipping_instructions, s1, set( ship ) ] )
		
	] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK VERS AND REV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_vers_and_rev, [
%=======================================================================

	  q0n(line)
	
	, generic_horizontal_details( [ [ `VERS`, `.`, tab, `REV`, `.` ] ] )
	
	, check( generic_hook(start) = Left )
	
	, vers_rev_line(1,Left,180)
	
] ).

%=======================================================================
i_line_rule( vers_rev_line, [
%=======================================================================

	  or( [
	
		[ `0`, tab, `0000`, trace( [ `passed` ] ) ]
		
		, [ a(d), tab, a(d), delivery_note_reference( `SPECIAL RULE` ), trace( [ `failed` ] ) ]
		
	] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	  qn0(line), invoice_totals_line(3,250,500)
	
] ).

%=======================================================================
i_line_rule( invoice_totals_line, [
%=======================================================================

	  `TOTAL`, `PRICE`, generic_no( [ total_net, d ] )
	
	, check( total_net = Net ), total_invoice( Net )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, q0n( [

		  or( [
		
			  line_invoice_rule

			, line

		] )

	] )

	, line_end_line 

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `ITEM`, tab, `INT`, `.`, `CODE`, tab, `PART`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  `I`, `DATI`, `CONTRASSEGNATI`

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
	, or( [
	
		[ q01(line), generic_horizontal_details( [ `PER`, per, d, [ `NR`, newline ] ] )
			, check( sys_calculate_str_divide( line_unit_amount_x, per, Unit ) )
		]
		
		, check( line_unit_amount_x = Unit )
		
	] )
	
	, line_unit_amount( Unit )
	, trace( [ `line_unit_amount`, line_unit_amount ] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_no( [ line_order_line_number, d, tab ] )
	
	, or( [
	
		[ with( customer_comments ), generic_item( [ not_comments_, w ] ) ]
		
		, generic_item( [ customer_comments, w ] )
		
	] )
	
	, generic_item( [ line_item_for_buyer, w ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity_uom_code, w, q10(tab) ] )
	
	, generic_no( [ line_quantity, d ] )
	
	, generic_item( [ line_original_order_date, date, tab ] )
	
	, generic_no( [ line_unit_amount_x, d, newline ] )

] ).