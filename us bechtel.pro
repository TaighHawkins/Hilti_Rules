%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US BECHTEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_bechtel, `18 August 2014` ).

i_date_format( `m/d/y` ).

i_format_postcode( X, X ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

bespoke_e1edp19_segment( [ `098`, line_item ] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_date
	
	, get_order_number
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

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

	, buyer_registration_number( `US-ADAPTRI` )

	, or( [ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]   	%TEST
	    , supplier_registration_number( `P11_100` )                    	%PROD
	] )

	, or( [ 
	  [ test(test_flag), suppliers_code_for_buyer( `11256197` ) ]   	%TEST
	    , suppliers_code_for_buyer( `15878398` )                		%PROD
	] )

	, or( [ 
	  [ test(test_flag), delivery_note_number( `11256197` ) ]  		%TEST
	    , delivery_note_number( `15878398` )                   		%PROD
	] )

	, agent_name(`US_ADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, type_of_supply( `04` )
	
	, cost_centre( `Collection_Cust` )
	
	, buyer_dept( `USMWTTMPLAP` )
	, delivery_from_contact( `USMWTTMPLZV` )
	
	, total_net( `0` )
	, total_invoice( `0` )

	, sender_name( `Bechtel MWT` )

	, set( no_uom_transform )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO * DATES * CONTACT DETAILS * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,7,line), generic_horizontal_details( [ [ `Request`, `#`, tab, order_a(s1), tab, `Purchase`, `Order`, `#` ], order_b, s1, newline ] )
	  
	, check( order_a = A )
	, check( order_b = B )
	
	, check( strcat_list( [ B, `_`, A ], Order ) )
	
	, order_number( Order )
	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Time`, `of`, `Request` ], invoice_date, date ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, qn0( [ 
	
		or( [  line_invoice_rule
	
			, line_check_line
	
			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Line`, `Item`, tab ] ).
%=======================================================================
i_line_rule_cut( line_check_line, [ dum(d), q0n(anything), tab, qn0(anything), tab, dum(d), newline ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  or( [ [ line_invoice_line
	  
			, q10( [ line_bom_line
		
				, skip_ahead( qn0( line_alternate_line ) )
				
			] )
		
		]
		
		, [ line_na_line
		
			, line_bom_line
			
			, qn0( line_alternate_line )
			
		]
		
	] )

] ).


%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	  generic_item_cut( [ line_no, d, tab ] )
	  
	, generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ], tab ] )

	, generic_item_cut( [ line_descr, s1, tab ] )
	
	, q10( generic_item_cut( [ base_connection, s1, tab ] ) )
	
	, q01( generic_item_cut( [ base_orientation, s1, tab ] ) )
	
	, generic_item_cut( [ line_quantity, d, newline ] )
	
	, fill_in_empty_values
	
] ).

%=======================================================================
i_rule_cut( fill_in_empty_values, [
%=======================================================================
   
	  line_unit_amount( `0` )
	, line_net_amount( `0` )
	, line_vat_amount( `0` )
	, line_vat_rate( `0` )
	, line_percent_discount( `0` )
	, line_amount_discount( `0` )
	, line_total_amount( `0` )
	, line_quantity_uom_code( `PC` )
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_alternate_line, [
%=======================================================================
	  
	  generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ], tab ] )

	, generic_item_cut( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, newline ] )
	
	, fill_in_empty_values
	
] ).

%=======================================================================
i_line_rule_cut( line_bom_line, [ `BOM`, `Item`, `#` ] ).
%=======================================================================
i_line_rule_cut( line_na_line, [
%=======================================================================
	  
	  generic_item( [ na_no, d, tab ] )
	  
	, `N`, `/`, `A`
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).