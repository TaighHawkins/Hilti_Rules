%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - AU NILSEN (SA) PTY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( au_nilsen_sa_pty, `27 July 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	, gen_capture( [ [ gen_beof, `Date` ], 200, invoice_date, date, newline ] )
	
	, gen_vert_capture( [ [ `Despatch`, `Notes`, newline ], shipping_instructions, s1, newline ] )
	
	, get_delivery_address
	
	, get_buyer_and_delivery_contact
	
	, get_buyer_and_delivery_ddi

	, get_invoice_lines
	
	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `AU-ADAPTRI` )

	, or( [ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, or( [ 
	  [ test(test_flag), suppliers_code_for_buyer( `10493821` ) ]    %TEST
	    , suppliers_code_for_buyer( `11127861` )                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, sender_name( `Nilsen (SA) Pty Ltd.` ) % 2 branches of BHP use these rules.

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	  q(0,6,line)
	
	, generic_vertical_details( [ [ `PURCHASE`, `ORDER`, newline ], `PURCHASE`, q(0,2), end, order_number_x, s1, newline ] )
	
	, check( strip_string2_from_string1( order_number_x, ` `, ON ) )
	
	, order_number( ON )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	  q0n(line), delivery_start_line
	
	, delivery_thing( [ delivery_party ] )
	
	, delivery_thing( [ delivery_dept ] )
	
	, delivery_thing( [ delivery_street ] )
	
	, shipping_instructions_line
	
	, delivery_city_state_postcode_line
	
] ).

%=======================================================================
i_line_rule( delivery_start_line, [
%=======================================================================

	  q0n( [ a(s1), tab ] )
	
	, read_ahead( [ `Deliver`, `To`, `:` ] )
	
	, generic_item( [ delivery_left_margin, s1 ] )
	
] ).

%=======================================================================
i_line_rule( delivery_thing( [ Var ] ), [
%=======================================================================

	  nearest( delivery_left_margin(start), 10, 10 )
	
	, generic_item( [ Var, s1 ] )
	
] ).

%=======================================================================
i_line_rule( shipping_instructions_line, [
%=======================================================================

	  nearest( delivery_left_margin(start), 10, 10 )
	
	, read_ahead( [ `All`, `drivers` ] )
	
	, append( shipping_instructions(s1), ` `, `` )
	
] ).

%=======================================================================
i_line_rule( delivery_city_state_postcode_line, [
%=======================================================================

	  nearest( delivery_left_margin(start), 10, 10 )
	
	, generic_item( [ delivery_city_x, sf ] )
	, check( string_to_upper( delivery_city_x, City ) )
	, delivery_city( City )
	
	, generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,4), end ] ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER AND DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_and_delivery_contact, [
%=======================================================================

	  q0n(line)
	
	, generic_horizontal_details( [ [ gen_beof, `Contact`, `:` ], contact, sf, or( [ `/`, gen_eof ] ) ] )
	
	, check( string_string_replace( contact, `.`, ` `, Contact ) )
	
	, buyer_contact( Contact )
	, delivery_contact( Contact )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER AND DELIVERY DDI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_and_delivery_ddi, [
%=======================================================================

	  q0n(line)
	
	, generic_line( [ [ `Contact`, `:` ] ] )
	
	, generic_line( [ [ `Phone`, `:` ] ] )
	
	, generic_horizontal_details( [ [ gen_beof, `Phone`, `:` ], ddi, s1 ] )
	
	, check( strip_string2_from_string1( ddi, ` `, DDI ) )
	
	, buyer_ddi( DDI )
	, delivery_ddi( DDI )
	
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

	, qn0( [ peek_fails( line_end_line )

		, or( [ line_invoice_rule

			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Item`, `Description`, tab, `Ordered`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  `Line`, `ItemTotal`, tab
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_no_line
	
	, or( [
	
		line_values_line
		
		, [ line_values_line_1, line_values_line_2 ]
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_no_line, [
%=======================================================================
   
	  generic_no( [ line_order_line_number, d, tab ] )
	
	, `Job`, `No`, `:`, word, newline
	
] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================
   
	  or( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ], q10(tab) ] ), line_item( `Missing` ) ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, q(0,3, [ append( line_descr(s1), ` `, `` ), tab ] )
	
	, q01( append( line_descr(sf), ` `, `` ) )
	
	, generic_no( [ qty_ord, d, tab ] )
	
	, generic_no( [ qty_cancel, d, tab ] )
	
	, generic_no( [ line_quantity, d, tab ] )
	
	, `$`, generic_no( [ line_unit_amount, d, tab ] )
	
	, `$`, generic_no( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_values_line_1, [
%=======================================================================
   
	  generic_no( [ qty_ord, d, tab ] )
	
	, generic_no( [ qty_cancel, d, tab ] )
	
	, generic_no( [ line_quantity, d, tab ] )
	
	, `$`, generic_no( [ line_unit_amount, d, tab ] )
	
	, `$`, generic_no( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_values_line_2, [
%=======================================================================
   
	  generic_item( [ line_item, [ begin, q(dec,4,10), end ], q10(tab) ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, q(0,2, [ append( line_descr(s1), ` `, `` ), tab ] )
	
	, append( line_descr(s1), ` `, `` )
	
	, newline
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line)

	, generic_horizontal_details( [ [ `Line`, `ItemTotal` ], 200, total_net, d, newline ] )

	, check( total_net = Net )
	
	, total_invoice( Net )
	
] ).