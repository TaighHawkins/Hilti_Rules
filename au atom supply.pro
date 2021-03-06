%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - ATOM SUPPLY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( atom_supply, `30 January 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

i_op_param( xml_transform( delivery_city, In ), _, _, _, Out )
:- string_to_upper( In, Out ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ get_fixed_variables, check_for_warehouse_only ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_check_header_line, [ q0n(anything), read_ahead( [ `Deliver`, tab ] ), generic_item( [ delivery_hook, s1 ] ) ] ).
%=======================================================================
i_rule( check_for_warehouse_only, [ 
%=======================================================================

	  q(0,30,line), delivery_check_header_line
	  
	, q(0,5,line), generic_horizontal_details( [ [ `WA`, `Warehouses`, `Only` ] ] )
	
	, delivery_note_reference( `special_rule` )
	, set( do_not_process )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_buyer_contact
	
	, get_buyer_ddi
	
	, get_buyer_fax
	
	, get_buyer_email
	
	, get_order_number
	
	, get_order_date
	
	, get_delivery_address
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals

] ):- not( grammar_set( do_not_process ) ).

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

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10493821` ) ]
		, suppliers_code_for_buyer( `11139613` )
	] )

	, delivery_party( `Atom Supply` )
	
	, sender_name( `Atom Supply` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q(0,10,line), delivery_header_line
	  
	, q(1,3,line)

	, delivery_thing_line( [ delivery_street ] )

	, delivery_city_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ q0n(anything), read_ahead( [ `Deliver`, tab ] ), generic_item( [ delivery_hook, s1 ] ) ] ).
%=======================================================================
i_line_rule( delivery_thing_line( [ Variable ] ), [ 
%=======================================================================

	  nearest( delivery_hook(start), 10, 10 )
	  
	, peek_fails( [ `TO` ] )

	, generic_item( [ Variable, s1 ] )
	
] ).

%=======================================================================
i_line_rule( delivery_city_postcode_line, [ 
%=======================================================================
	
	  nearest( delivery_hook(start), 10, 10 )

	, delivery_city(sf)
	
	, delivery_state(w)

	, delivery_postcode(f( [ begin, q(dec,4,5), end ] ) )
	
	, trace( [ `other delivery stuffs`, delivery_postcode, delivery_state, delivery_city ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO * DATES * CONTACT DETAILS * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ read_ahead( [ `Purchase`, `Order` ] ), order_hook, w ] )
	  
	, q(0,2,line), generic_line( [ [ nearest( order_hook(end), 10, 10 ), generic_item( [ order_number, s1 ] ) ] ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Date`, `of`, `Issue`, `:` ], invoice_date, date ] )
	  
] ).

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Created`, `By`, `:` ], buyer_contact, s1, newline ] )

	, check( buyer_contact = Con )
	
	, delivery_contact( Con )
	
] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `Phone`, `:` ], buyer_ddi, s1, newline ] )
	  
	, check( buyer_ddi = DDI )
	
	, delivery_ddi( DDI )
	
] ).

%=======================================================================
i_rule( get_buyer_fax, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `Fax`, `:` ], buyer_fax, s1, newline ] )
	  
	, check( buyer_fax = Fax )
	
	, delivery_fax( Fax )
	
] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ or( [ tab, at_start ] ), `Email`, `:` ], buyer_email, s1 ] )
	  
	, check( buyer_email = Email )
	
	, delivery_email( Email )

] ).

%=======================================================================
i_rule( get_totals, [ qn0(line), totals_line ] ).
%=======================================================================
i_line_rule( totals_line, [
%=======================================================================

	  q0n(anything), `Sub`, `Total`, `Excl`, `.`, `GST`, tab
	  
	, read_ahead( [ generic_item( [ total_net, d, newline ] ) ] )
	
	, generic_item( [ total_invoice, d, newline ] )
	
	, or( [ [ with( invoice, delivery_charge, Charge )
	
			, check( sys_calculate_str_subtract( total_net, Charge, Net_1 ) )
			
			, net_subtotal_2( Charge )
			
			, gross_subtotal_2( Charge )
			
		]
		
		, [ without( delivery_charge )
		
			, check( total_net = Net_1 )
			
		]
		
	] )
	
	, net_subtotal_1( Net_1 )
	
	, gross_subtotal_1( Net_1 )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		or( [  line_delivery_line
		
			, line_invoice_line
		
			, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Vendor`, `PN`, tab, q10( [ `Atom`, `PN` ] ), `Description` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ q0n( [ dummy(s1), tab ] ), `Sub`, `Total` ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	  or( [ generic_item( [ line_item, s1, tab ] ), line_item( `Missing` ) ] )
	  
	, generic_item( [ line_item_for_buyer, w, q10( tab ) ] )

	, generic_item( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_original_order_date_x, date, tab ] )
	
	, generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item( [ price_per, s1, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )
	
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_delivery_line, [
%=======================================================================
   
	  `10000000`
	  
	, qn0(anything), tab
	
	, generic_item( [ delivery_charge, d, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).