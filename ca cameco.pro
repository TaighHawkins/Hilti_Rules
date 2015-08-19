%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CA CAMECO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ca_cameco, `16 June 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
i_user_field( invoice, picking_instructions, `Picking Instructions` ).
i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).

bespoke_e1edp19_segment( [ `098`, line_item ] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, gen_vert_capture( [ [ `PO`, `number`, `/`, `date` ], order_number, sf, [ `/`, generic_item( [ invoice_date, date, newline ] ) ] ] )

	, get_delivery_address

	, get_buyer_and_delivery_contact_info

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_lines

	, gen_capture( [ [ `Total`, `net`, `value`, `excl`, `.`, `tax`, `CAD` ], 300, total_net, d, newline ] )
	, gen_capture( [ [ `Total`, `net`, `value`, `excl`, `.`, `tax`, `CAD` ], 300, total_invoice, d, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `CA-ADAPTRI` )

	, or( [ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, or( [ 
		[ test(test_flag), suppliers_code_for_buyer( `11263738` ) ]
		, suppliers_code_for_buyer( `10687952` )
	] )
	
	, agent_name(`CA_ADAPTRIS`)
	, agent_code_3(`6800`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, type_of_supply( `01` )
	
	, cost_centre( `Standard` )
	
	, buyer_ddi( `514-738-3033` )
	
	, buyer_fax( `514-738-9507` )
	
	, delivery_party( `CAMECO CORPORATION` )
	
	, sender_name( `Cameco` )
	
	, set( no_uom_transform )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	  q(0,30,line)
	
	, delivery_start_line
	
	, delivery_thing( [ delivery_dept ] )
	
	, q(0,2,line)
	
	, delivery_thing( [ delivery_street ] )
	
	, delivery_city_state_and_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_start_line, [
%=======================================================================

	  read_ahead( [ `Ship`, `to`, `:` ] )
	
	, generic_item( [ delivery_hook, s1 ] )

] ).

%=======================================================================
i_line_rule( delivery_thing( [ Var ] ), [
%=======================================================================

	  nearest( delivery_hook(start), 10, 10 )
	
	, generic_item( [ Var, s1 ] )

] ).

%=======================================================================
i_line_rule( delivery_city_state_and_postcode_line, [
%=======================================================================

	nearest( delivery_hook(start), 10, 10 )
	
	, generic_item( [ delivery_city, sf ] )

	, generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] )
	
	, generic_item( [ delivery_postcode, s1 ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER AND DELIVERY CONTACT INFO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_and_delivery_contact_info, [
%=======================================================================

	  q0n(line)
	
	, generic_horizontal_details( [ [ `Buyer`, `/`, `Telephone`, newline ] ] )
	
	, q01(line)
	
	, contact_and_ddi_line
	
	, q01(line)
	
	, generic_horizontal_details( [ [ `e`, `-`, `mail`, `:` ], email, s1, newline ] )
	
	, check( i_user_check( extract_contact_from_email, email, Contact ) )
	
	, q01(line)
	
	, generic_vertical_details( [ [ `Our`, `fax`, `number` ], fax, s1, newline ] )
	
	, buyer_contact( Contact )
	, delivery_contact( Contact )
	
	, check( ddi = DDI )
	, buyer_ddi( DDI )
	, delivery_ddi( DDI )
	
	, check( email = Email )
	, buyer_email( Email )
	, delivery_email( Email )
	
	, check( fax = Fax )
	, buyer_fax( Fax )
	, delivery_fax( Fax )

] ).

%=======================================================================
i_line_rule( contact_and_ddi_line, [
%=======================================================================

	  nearest( generic_hook(start), 10, 10 )
	
	, generic_item( [ dummy, sf, `/` ] )
	
	, generic_item( [ ddi, s1, newline ] )
	
] ).

%-----------------------------------------------------------------------
i_user_check( extract_contact_from_email, Email, Contact )
%-----------------------------------------------------------------------
:-
	sys_string_split( Email, `@`, [ Name | _ ] ),
	string_to_upper( Name, NAME ), trace( NAME ),
	sys_string_split( NAME, `_`, [ First, Last ] ),
	strcat_list( [ First, ` `, Last ], Contact ),
	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_lines, [
%=======================================================================

	  line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [
		
			generic_line( [ [ `_`, `_`, `_`, `_`, `_`, `_` ] ] )
			
			, line_invoice_rule
			
			, line

		] )
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Line`, `#`, tab, `|`, `Quantity`, tab, `|`, `U`, `/`, `M`, tab

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  or( [
	
		[ `Total`, `net`, `value`, `excl`, `.` ]
		
		, [ `Page`, a(d), `of` ]
		
	] )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
	, generic_horizontal_details( [ [ `Vendor`, `Part`, `Number`, `:` ], line_item, w, [ q0n(word), newline ] ] )
	
	, generic_line( [ generic_item( [ line_descr, s1, newline ] ) ] )
	
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	  generic_no( [ line_no, d, tab ] )
	
	, generic_no( [ line_quantity, d, tab ] )
	
	, or( [
	
		[ `EACH`, line_quantity_uom_code( `PC` ) ]
		
		, generic_item( [ dummy_uom, s1 ] )
		
	] ), tab
	
	, q01( generic_item( [ line_item_for_buyer, s1, tab ] ) )
	
	, generic_no( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ per, w, tab ] )
	
	, generic_no( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).